import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var store: TrainingStore
    @Environment(\.dismiss) private var dismiss
    let result: TrainingResult
    var isLatest = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        Image(systemName: result.completed ? "checkmark.seal.fill" : "flag.checkered")
                            .font(.largeTitle).foregroundStyle(Palette.accent).accessibilityHidden(true)
                        Text(result.completed ? LocalizedStringKey("result.completed") : LocalizedStringKey("result.stopped"))
                            .font(.system(.title, design: .rounded, weight: .bold))
                        Text(LocalizedStringKey(result.settings.operation.titleKey)).font(.headline)
                        Text(result.settings.rangeText).foregroundStyle(.secondary)
                    }
                }
                HStack(spacing: 12) {
                    StatTile(value: "\(result.accuracy)%", title: "stat.first.try")
                    StatTile(value: String(result.correctAnswers), title: "stat.solved")
                }
                HStack(spacing: 12) {
                    StatTile(value: String(result.incorrectAttempts), title: "stat.mistakes")
                    StatTile(value: String(result.skippedQuestions), title: "stat.skipped")
                }
                Card {
                    VStack(spacing: 12) {
                        LabeledContent("stat.best.streak", value: String(result.bestStreak))
                        Divider()
                        LabeledContent("stat.time", value: durationLabel)
                    }
                }
                Text("result.accuracy.hint").font(.caption).foregroundStyle(.secondary)
                if isLatest {
                    Button("action.again") {
                        store.configure { $0 = result.settings }
                        store.start()
                    }.buttonStyle(PrimaryButton()).accessibilityIdentifier("trainAgain")
                    Button("action.home") { dismiss() }.frame(maxWidth: .infinity)
                        .accessibilityIdentifier("backHome")
                }
            }.padding(20).frame(maxWidth: 620).frame(maxWidth: .infinity)
        }.background(Palette.background).navigationTitle("result.title").navigationBarTitleDisplayMode(.inline)
            .accessibilityIdentifier("resultScreen")
    }
    private var durationLabel: String {
        String(format: String(localized: "duration.format"), result.durationSeconds / 60, result.durationSeconds % 60)
    }
}
