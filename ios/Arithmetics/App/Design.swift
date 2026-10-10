import SwiftUI

enum Palette {
    static let accent = Color("Accent")
    static let onAccent = Color("OnAccent")
    static let background = Color("Canvas")
    static let ink = Color.primary
}

struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24))
    }
}

struct PrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline).padding(.vertical, 17).frame(maxWidth: .infinity)
            .foregroundStyle(Palette.onAccent)
            .background(Palette.accent.opacity(isEnabled ? 1 : 0.35), in: RoundedRectangle(cornerRadius: 18))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct StatTile: View {
    let value: String
    let title: LocalizedStringKey
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value).font(.system(.title, design: .rounded, weight: .bold)).monospacedDigit()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding(16).background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20))
    }
}

extension TrainingSettings {
    var rangeText: String {
        operation.usesTable ? String(localized: "table.title") : String(format: String(localized: "range.format"), range.rawValue)
    }
}
