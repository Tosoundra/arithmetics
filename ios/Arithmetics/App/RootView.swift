import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: TrainingStore
    @State private var showTraining = false
    var body: some View {
        TabView {
            NavigationStack {
                HomeView(showTraining: $showTraining)
            }.tabItem { Label("tab.practice", systemImage: "square.grid.2x2") }
            NavigationStack { HistoryView() }
                .tabItem { Label("tab.progress", systemImage: "chart.bar.xaxis") }
            NavigationStack { AboutView() }
                .tabItem { Label("tab.about", systemImage: "info.circle") }
        }
        .fullScreenCover(isPresented: $showTraining) {
            NavigationStack {
                if store.snapshot.activeSession != nil { TrainingView() }
                else if let result = store.lastResult { ResultView(result: result, isLatest: true) }
                else { Color.clear.onAppear { showTraining = false } }
            }.tint(Palette.accent)
        }
        .alert("storage.title", isPresented: Binding(get: { store.storageWarning }, set: { if !$0 { store.dismissStorageWarning() } })) {
            Button("action.ok") { store.dismissStorageWarning() }
        } message: { Text("storage.message") }
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: TrainingStore
    @Binding var showTraining: Bool
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("home.eyebrow").font(.caption.weight(.bold)).tracking(2).foregroundStyle(Palette.accent)
                    Text("home.title").font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("home.subtitle").foregroundStyle(.secondary)
                }.padding(.vertical, 8)

                if let session = store.snapshot.activeSession {
                    Card {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("home.resume.title", systemImage: "arrow.clockwise").font(.headline)
                            Text(LocalizedStringKey(session.settings.operation.titleKey)).foregroundStyle(.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("home.operation").font(.headline)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(ArithmeticOperation.allCases) { operation in
                            operationButton(operation)
                        }
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 16) {
                        if store.snapshot.settings.operation.usesTable {
                            Label("table.title", systemImage: "number").font(.headline)
                            Text("table.hint").foregroundStyle(.secondary)
                        } else {
                            Text("home.range").font(.headline)
                            Picker("home.range", selection: Binding(get: { store.snapshot.settings.range }, set: { value in store.configure { $0.range = value } })) {
                                ForEach(NumberRange.allCases) { range in Text(range.rawValue.formatted()).tag(range) }
                            }.pickerStyle(.segmented).accessibilityIdentifier("numberRange")
                            Text("range.hint").font(.caption).foregroundStyle(.secondary)
                        }
                        Divider()
                        Text("home.length").font(.headline)
                        Picker("home.length", selection: Binding(get: { store.snapshot.settings.length }, set: { value in store.configure { $0.length = value } })) {
                            Text("10").tag(TrainingLength.ten)
                            Text("20").tag(TrainingLength.twenty)
                            Text("length.unlimited").tag(TrainingLength.unlimited)
                        }.pickerStyle(.segmented).accessibilityIdentifier("trainingLength")
                    }
                }.disabled(store.snapshot.activeSession != nil)
                Label("home.offline", systemImage: "checkmark.shield").font(.caption)
                    .foregroundStyle(.secondary).frame(maxWidth: .infinity)
            }.padding(20).frame(maxWidth: 620).frame(maxWidth: .infinity)
        }.background(Palette.background)
            .safeAreaInset(edge: .bottom, spacing: 0) { primaryAction }
            .navigationTitle("app.name").navigationBarTitleDisplayMode(.inline)
    }

    private var primaryAction: some View {
        let hasSession = store.snapshot.activeSession != nil
        return Button(LocalizedStringKey(hasSession ? "action.resume" : "action.start")) {
            if store.snapshot.activeSession == nil { store.start() }
            showTraining = true
        }.buttonStyle(PrimaryButton())
            .accessibilityIdentifier(hasSession ? "resumeTraining" : "startTraining")
            .padding(.horizontal, 20).padding(.vertical, 12)
            .frame(maxWidth: 620).frame(maxWidth: .infinity)
            .background(Palette.background)
    }

    private func operationButton(_ operation: ArithmeticOperation) -> some View {
        let selected = store.snapshot.settings.operation == operation
        return Button { store.configure { $0.operation = operation } } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text(operation.symbol).font(.system(size: 36, weight: .medium, design: .rounded)).accessibilityHidden(true)
                Text(LocalizedStringKey(operation.titleKey)).font(.subheadline.weight(.semibold))
            }.frame(maxWidth: .infinity, alignment: .leading).padding(18)
                .foregroundStyle(selected ? Palette.onAccent : Palette.ink)
                .background(selected ? Palette.accent : Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
        }.buttonStyle(.plain).accessibilityIdentifier("operation-\(operation.rawValue)")
            .accessibilityAddTraits(selected ? .isSelected : [])
            .disabled(store.snapshot.activeSession != nil)
    }
}
