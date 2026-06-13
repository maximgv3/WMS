import SwiftUI
/// Settings are postponed until the app has configurable options.
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()
            VStack {
                
            }
            .padding(16)
        }
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
