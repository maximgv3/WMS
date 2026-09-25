import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var sessionStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: LoginViewModel
    @State private var isScanningEnabled = false
    @State private var isCameraDenied = false
    private let cameraPermissionService = CameraPermissionService()

    #if DEBUG
        @State private var isDemoModeOn = false

        private let demoBadgeId = "1023780"
        private let demoWrongCode = "0000000000"
    #endif

    init(authService: AuthServiceProtocol) {
        self.viewModel = .init(authService: authService)
    }

    var body: some View {
        ZStack {
            ColorPalette.brandPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 28,
                            topTrailingRadius: 28
                        )
                        .fill(ColorPalette.surfacePrimary)
                        .ignoresSafeArea(edges: .bottom)
                    }
            }
        }
        .errorBanner(
            title: .loginCouldNotSignIn,
            message: errorMessage
        )
        .onAppear {
            updateCameraAccess()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            updateCameraAccess()
        }
    }

    private var header: some View {
        ModuleHeader(title: .loginTitle)
            #if DEBUG
                .overlay(alignment: .trailing) {
                    demoMenu
                        .padding(.trailing, 20)
                }
            #endif
    }

    private var content: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)
            IconChip(systemName: "person.text.rectangle", size: 88)
            Text(.loginScanYourBadge)
                .font(.system(size: 24, weight: .semibold))
            Text(.loginScanBadgeHint)
                .multilineTextAlignment(.center)
                .foregroundStyle(ColorPalette.brandMuted)
            Spacer(minLength: 0)
            scanner
                .overlay {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.large)
                            .padding(16)
                            .background(
                                .regularMaterial,
                                in: RoundedRectangle(
                                    cornerRadius: 16,
                                    style: .continuous
                                )
                            )
                    }
                }
        }
        .foregroundStyle(ColorPalette.textPrimary)
        .padding(16)
    }

    @ViewBuilder
    private var scanner: some View {
        #if DEBUG
            if isDemoModeOn {
                demoControls
            } else {
                cameraScanner
            }
        #else
            cameraScanner
        #endif
    }

    @ViewBuilder
    private var cameraScanner: some View {
        if isCameraDenied {
            cameraDeniedCard
        } else {
            ScannerView(
                isScanningEnabled: $isScanningEnabled,
                idleText: .loginScanBadgePrompt,
                activeText: .loginScanningBadge,
                previewHeight: 240,
                onScan: { code in processScan(code) }
            )
        }
    }

    private var cameraDeniedCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.fill")
                .font(.system(size: 32))
            Text(.cameraNoCameraAccess)
                .font(.system(size: 20, weight: .semibold))
            Text(.cameraEnableInSettings)
                .font(.system(size: 15))
                .foregroundStyle(ColorPalette.brandMuted)
                .multilineTextAlignment(.center)
            Button(.cameraOpenSettings) {
                openAppSettings()
            }
            .buttonStyle(.borderedProminent)
            .tint(ColorPalette.accentPrimary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    ColorPalette.brandMuted.opacity(0.35),
                    lineWidth: 1
                )
        }
    }

    #if DEBUG
        private var demoMenu: some View {
            Menu {
                Button {
                    isDemoModeOn.toggle()
                    isScanningEnabled = false
                } label: {
                    Label(
                        .commonDemoMode,
                        systemImage:
                            "arrow.trianglehead.2.clockwise.rotate.90.camera"
                    )
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(ColorPalette.textInverted)
                    .padding(4)
                    .glassIfAvailable()
            }
        }

        private var demoControls: some View {
            HStack(spacing: 12) {
                Button {
                    processScan(demoWrongCode)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(ColorPalette.error)
                        .frame(width: 56, height: 56)
                        .background(ColorPalette.error.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Button {
                    processScan(demoBadgeId)
                } label: {
                    Text(.loginBadge)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(ColorPalette.textInverted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(ColorPalette.brandPrimary)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            )
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        ColorPalette.brandMuted.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1, dash: [6])
                    )
            }
        }
    #endif

    private var errorText: String? {
        switch viewModel.lastError {
        case .unknownId:
            return String(localized: .loginBadgeNotFound)
        case .alreadyAuthorizedOnOtherDevice:
            return String(localized: .loginAccountInUseOnAnotherDevice)
        case nil:
            return nil
        }
    }

    private var errorMessage: Binding<String?> {
        Binding(
            get: { errorText },
            set: { if $0 == nil { viewModel.clearError() } }
        )
    }

    private func processScan(_ code: String) {
        Task {
            let isSignedIn = await viewModel.signIn(badgeId: code)

            if isSignedIn {
                FeedbackService.playSuccess()
                sessionStore.signIn(badgeId: code)
            } else if viewModel.lastError != nil {
                FeedbackService.playError()
            }
        }
    }

    private func updateCameraAccess() {
        isCameraDenied = cameraPermissionService.blockReason() == .denied
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    LoginView(authService: AuthServiceMock())
        .environment(SessionStore())
}
