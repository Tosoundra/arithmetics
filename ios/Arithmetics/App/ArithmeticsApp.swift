import SwiftUI

@main
@MainActor
struct ArithmeticsApp: App {
    @StateObject private var store = TrainingStore()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store).tint(Palette.accent)
                .preferredColorScheme(ProcessInfo.processInfo.arguments.contains("--ui-testing") && ProcessInfo.processInfo.arguments.contains("--dark-mode") ? .dark : nil)
        }
    }
}
