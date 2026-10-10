import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: TrainingStore
    var body: some View {
        ScrollView {
            if store.snapshot.history.isEmpty {
                ContentUnavailableView("history.empty.title", systemImage: "chart.bar.xaxis", description: Text("history.empty.message"))
                    .padding(.top, 80).accessibilityIdentifier("emptyHistory")
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        StatTile(value: String(store.snapshot.history.count), title: "stat.sessions")
                        StatTile(value: String(store.snapshot.history.reduce(0) { $0 + $1.correctAnswers }), title: "stat.solved")
                    }
                    HStack(spacing: 12) {
                        StatTile(value: "\(accuracy)%", title: "stat.first.try")
                        StatTile(value: String(store.snapshot.history.map(\.bestStreak).max() ?? 0), title: "stat.best.streak")
                    }
                    Text("history.limit").font(.caption).foregroundStyle(.secondary)
                    ForEach(store.snapshot.history) { result in
                        NavigationLink { ResultView(result: result) } label: {
                            Card {
                                HStack(spacing: 14) {
                                    Text(result.settings.operation.symbol).font(.system(size: 28, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Palette.accent).frame(width: 32).accessibilityHidden(true)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(LocalizedStringKey(result.settings.operation.titleKey)).font(.headline)
                                        Text(result.endedAt.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(.secondary)
                                        if !result.completed { Text("result.stopped").font(.caption).foregroundStyle(.secondary) }
                                    }
                                    Spacer()
                                    Text("\(result.accuracy)%").font(.headline).monospacedDigit()
                                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }.buttonStyle(.plain).accessibilityIdentifier("historyRow")
                    }
                }.padding(20).frame(maxWidth: 620).frame(maxWidth: .infinity)
            }
        }.background(Palette.background).navigationTitle("history.title")
    }
    private var accuracy: Int {
        let total = store.snapshot.history.reduce(0) { $0 + $1.completedQuestions }
        let first = store.snapshot.history.reduce(0) { $0 + $1.correctOnFirstTry }
        return total == 0 ? 0 : Int((Double(first) / Double(total) * 100).rounded())
    }
}
