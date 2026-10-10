import SwiftUI

struct TrainingView: View {
    @EnvironmentObject private var store: TrainingStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var answer = ""
    @State private var feedback: AnswerOutcome?
    @State private var showExit = false
    @State private var showReveal = false
    @State private var successTrigger = 0
    @State private var errorTrigger = 0

    var body: some View {
        ScrollView {
            if let session = store.snapshot.activeSession {
                VStack(spacing: 20) {
                    HStack {
                        Text(LocalizedStringKey(session.settings.operation.titleKey)).font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(session.settings.rangeText).font(.caption).foregroundStyle(.secondary)
                    }
                    if let target = session.settings.length.target {
                        ProgressView(value: Double(session.completedQuestions), total: Double(target))
                            .accessibilityLabel(Text("practice.progress"))
                    }
                    Text(questionLabel(session)).font(.caption.weight(.medium)).foregroundStyle(.secondary)
                    Card {
                        VStack(spacing: 22) {
                            Text(session.problem.expression).font(.system(size: 46, weight: .semibold, design: .rounded))
                                .minimumScaleFactor(0.5).lineLimit(1)
                                .accessibilityIdentifier("problemExpression")
                            Text(displayedAnswer(session).isEmpty ? "?" : displayedAnswer(session))
                                .font(.system(size: 40, weight: .bold, design: .rounded)).monospacedDigit()
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Palette.background, in: RoundedRectangle(cornerRadius: 14))
                                .accessibilityLabel(Text("practice.answer"))
                                .accessibilityValue(displayedAnswer(session).isEmpty ? String(localized: "practice.empty") : displayedAnswer(session))
                                .accessibilityIdentifier("answerDisplay")
                            feedbackView(session).frame(minHeight: 28)
                        }.frame(maxWidth: .infinity)
                    }
                    if session.phase == .answering {
                        numberPad
                        Button("action.check", action: check).buttonStyle(PrimaryButton())
                            .disabled(answer.isEmpty).accessibilityIdentifier("checkAnswer")
                        Button("action.reveal") { showReveal = true }.font(.subheadline)
                            .accessibilityIdentifier("revealAnswer")
                    } else {
                        Button(LocalizedStringKey(session.targetReached ? "action.results" : "action.next")) {
                            answer = ""; feedback = nil; store.advance()
                        }.buttonStyle(PrimaryButton()).accessibilityIdentifier("nextProblem")
                    }
                    HStack(spacing: 12) {
                        StatTile(value: String(session.correctAnswers), title: "stat.solved")
                        StatTile(value: String(session.incorrectAttempts), title: "stat.mistakes")
                    }
                }.padding(20).frame(maxWidth: 620).frame(maxWidth: .infinity)
            }
        }.background(Palette.background).navigationTitle("practice.title").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("action.close", systemImage: "xmark") { showExit = true }
                        .accessibilityIdentifier("closeTraining")
                }
            }
            .confirmationDialog("exit.title", isPresented: $showExit, titleVisibility: .visible) {
                Button("action.pause") { dismiss() }
                Button("action.finish") { store.finish(); if store.lastResult == nil { dismiss() } }
                Button("action.cancel", role: .cancel) {}
            } message: { Text("exit.message") }
            .confirmationDialog("reveal.title", isPresented: $showReveal, titleVisibility: .visible) {
                Button("action.reveal", role: .destructive) { store.reveal(); answer = ""; feedback = nil }
                Button("action.cancel", role: .cancel) {}
            } message: { Text("reveal.message") }
            .sensoryFeedback(.success, trigger: successTrigger)
            .sensoryFeedback(.warning, trigger: errorTrigger)
    }

    private var numberPad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(1...9, id: \.self) { digit in digitButton(digit) }
            Button { answer = ""; feedback = nil } label: { Text("action.clear").font(.subheadline) }
                .accessibilityIdentifier("clearAnswer").buttonStyle(KeyButtonStyle())
            digitButton(0)
            Button { if !answer.isEmpty { answer.removeLast() }; feedback = nil } label: { Image(systemName: "delete.left") }
                .accessibilityLabel(Text("action.backspace")).accessibilityIdentifier("backspace").buttonStyle(KeyButtonStyle())
        }
    }

    private func digitButton(_ digit: Int) -> some View {
        Button {
            guard answer.count < 5 else { return }
            answer = answer == "0" ? String(digit) : answer + String(digit)
            feedback = nil
        } label: { Text(String(digit)).font(.system(.title2, design: .rounded, weight: .semibold)) }
            .accessibilityIdentifier("digit-\(digit)").buttonStyle(KeyButtonStyle())
    }

    @ViewBuilder private func feedbackView(_ session: TrainingSession) -> some View {
        if session.phase == .correct {
            Label("feedback.correct", systemImage: "checkmark.circle.fill").foregroundStyle(Palette.accent)
                .accessibilityIdentifier("correctFeedback")
        } else if session.phase == .revealed {
            Text(String(format: String(localized: "feedback.revealed.format"), session.problem.answer))
                .foregroundStyle(.secondary).accessibilityIdentifier("revealedFeedback")
        } else if feedback == .incorrect {
            Label("feedback.incorrect", systemImage: "arrow.clockwise").foregroundStyle(.orange)
                .accessibilityIdentifier("incorrectFeedback")
        } else { Text("practice.input.hint").font(.subheadline).foregroundStyle(.secondary) }
    }

    private func check() {
        let outcome = store.submit(answer)
        if reduceMotion { feedback = outcome }
        else { withAnimation(.easeOut(duration: 0.15)) { feedback = outcome } }
        if outcome == .correct { successTrigger += 1 }
        if outcome == .incorrect { errorTrigger += 1; answer = "" }
    }

    private func displayedAnswer(_ session: TrainingSession) -> String {
        session.phase == .answering ? answer : String(session.problem.answer)
    }

    private func questionLabel(_ session: TrainingSession) -> String {
        if let target = session.settings.length.target {
            return String(format: String(localized: "practice.question.format"), session.questionNumber, target)
        }
        return String(format: String(localized: "practice.free.question.format"), session.questionNumber)
    }
}

private struct KeyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.frame(maxWidth: .infinity, minHeight: 56)
            .foregroundStyle(Color.primary)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .opacity(configuration.isPressed ? 0.65 : 1)
    }
}
