import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var store: TrainingStore
    @State private var showReset = false
    @State private var showPrivacy = false
    var body: some View {
        List {
            Section {
                Label("app.name", systemImage: "square.grid.2x2").font(.headline)
                Text("about.description").foregroundStyle(.secondary)
                LabeledContent("about.version", value: "1.0.0")
            }
            Section("about.rules.title") {
                Text("about.rules.retry")
                Text("about.rules.range")
                Text("about.rules.table")
                Text("result.accuracy.hint")
            }
            Section("about.privacy.title") {
                Label("home.offline", systemImage: "checkmark.shield")
                Button("about.privacy.link") { showPrivacy = true }
                Link("about.support", destination: URL(string: "https://github.com/Tosoundra/arithmetics/issues")!)
            }
            Section {
                Button("action.reset", role: .destructive) { showReset = true }
                    .accessibilityIdentifier("resetProgress")
            } footer: { Text("reset.hint") }
        }.navigationTitle("tab.about")
            .sheet(isPresented: $showPrivacy) {
                NavigationStack {
                    ScrollView { Text("privacy.text").padding(24).frame(maxWidth: 620, alignment: .leading) }
                        .navigationTitle("about.privacy.link").navigationBarTitleDisplayMode(.inline)
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("action.done") { showPrivacy = false } } }
                }
            }
            .alert("reset.title", isPresented: $showReset) {
                Button("action.reset", role: .destructive) { store.clearProgress() }
                Button("action.cancel", role: .cancel) {}
            } message: { Text("reset.message") }
    }
}
