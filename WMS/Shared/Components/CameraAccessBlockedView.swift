import SwiftUI

struct CameraAccessBlockedView: View {
    @State private var isArrowVisible = false
    let blockReason: CameraAccessBlockReason
    let onAccessGranted: () -> Void
    let onAccessDenied: () -> Void
    let permissionService: CameraPermissionService

    var body: some View {
        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 40))
                Text("Нет доступа к камере")
                    .font(.system(size: 24, weight: .semibold))
                switch blockReason {
                case .notDetermined:
                    Text("Нажмите продолжить и разрешите доступ к камере в системном окне.")
                        .font(.system(size: 16))
                        .foregroundStyle(ColorPalette.brandMuted)
                        .multilineTextAlignment(.center)

                        Image(systemName: "arrow.down")
                            .font(.system(size: 36))
                            .opacity(isArrowVisible ? 1 : 0)
                            .offset(y: isArrowVisible ? 0 : 12)
                            .animation(.easeOut(duration: 0.35), value: isArrowVisible)
                    Spacer()
                case .denied:
                    Text("Включите доступ к камере в настройках приложения.")
                        .font(.system(size: 16))
                        .foregroundStyle(ColorPalette.brandMuted)
                        .multilineTextAlignment(.center)

                    Button("Открыть настройки") {
                        openAppSettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ColorPalette.accentPrimary)
                }
            }
            .foregroundStyle(ColorPalette.brandPrimary)
            .padding(24)
        }
        .task {
            guard blockReason == .notDetermined else { return }
            try? await Task.sleep(for: .seconds(1))

            withAnimation(.easeOut(duration: 0.35)) {
                isArrowVisible = true
            }
            try? await Task.sleep(for: .seconds(0.35))

            let granted = await permissionService.requestAccess()

            if granted {
                onAccessGranted()
            } else {
                onAccessDenied()
            }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    CameraAccessBlockedView(
        blockReason: .notDetermined,
        onAccessGranted: {},
        onAccessDenied: {},
        permissionService: CameraPermissionService()
    )
}
