import SwiftUI

struct ContentView: View {
    @AppStorage(AppSettings.Key.colorScheme) private var appColorScheme =
        AppColorScheme.system

    var body: some View {
        TabView {
            OperationsListView()
                .tint(nil)
                .tabItem {
                    Label(.operationsTitle, systemImage: "shippingbox")
                }

            ProfileView(profileService: ProfileServiceMock())
                .tint(nil)
                .tabItem {
                    Label(.profileTitle, systemImage: "person.crop.circle")
                }
        }
        .tint(ColorPalette.accentPrimary)
        .foregroundStyle(ColorPalette.textPrimary)
        .onAppear {
            applyColorScheme(animated: false)
        }
        .onChange(of: appColorScheme) { _, _ in
            applyColorScheme(animated: true)
        }
    }

    // preferredColorScheme lands outside the animation transaction,
    // so the style goes to the window and UIKit cross-fades it.
    private func applyColorScheme(animated: Bool) {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
        guard let window else { return }

        let style = appColorScheme.interfaceStyle

        guard animated else {
            window.overrideUserInterfaceStyle = style
            return
        }

        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve
        ) {
            window.overrideUserInterfaceStyle = style
        }
    }
}
#Preview {
    ContentView()
        .environment(ActiveTaskStore())
}
