import SwiftUI

struct PutawayContainerView: View {

    @AppStorage("isPutawayOnboardingComplete") private
        var isPutawayOnboardingComplete = false
    @State private var viewModel: PutawayContainerViewModel
    @Binding private var path: [OperationType.WorkRoute]
    @State private var isScanningEnabled = false
    @State private var isOnboardingPresented = false

    #if DEBUG
        @AppStorage("isPutawayDemoModeOn") private var isDemoModeOn = false
        @State private var isDemoConfirmationPresented = false

        private let demoWrongContainerCode = "WMSCT000000"
    #endif

    private let task: PutawayTask

    init(
        task: PutawayTask,
        path: Binding<[OperationType.WorkRoute]>
    ) {
        self.task = task
        self.viewModel = PutawayContainerViewModel(container: task.container)
        self._path = path
    }

    var body: some View {
        VStack(spacing: 16) {
            containerCard
            scanner
            Text("Найдите контейнер на месте\nи отсканируйте его код")
                .multilineTextAlignment(.center)
                .foregroundStyle(ColorPalette.brandMuted)
                .frame(maxWidth: .infinity, minHeight: 56, maxHeight: .infinity)
        }
        .padding([.horizontal, .top], 16)
        .background(ColorPalette.backgroundPrimary.ignoresSafeArea())
        .errorBanner(
            title: "Не удалось начать раскладку",
            message: errorMessage
        )
        .onAppear {
            isOnboardingPresented = !isPutawayOnboardingComplete
            disableDemoMode()
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            OnboardingView(
                pages: OnboardingPages.Putaway.pages,
                completionImage: .putawayOnboardingEnd
            ) {
                isPutawayOnboardingComplete = true
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                exitMenu
            }
        }
    }

    private var errorText: String? {
        switch viewModel.lastError {
        case .wrongContainer:
            return "Это не тот контейнер"
        case .notACell, .notAnItem, .itemNotInTask, .cellIsFull, nil:
            return nil
        }
    }

    private var errorMessage: Binding<String?> {
        Binding(
            get: { errorText },
            set: { if $0 == nil { viewModel.clearError() } }
        )
    }

    private var exitMenu: some View {
        Menu {
            #if DEBUG
                Button {
                    demoButtonTapped()
                } label: {
                    Label(
                        "Демо-режим",
                        systemImage:
                            "arrow.trianglehead.2.clockwise.rotate.90.camera"
                    )
                }
            #endif

            Button {
                isPutawayOnboardingComplete = false
                isOnboardingPresented = true
                isScanningEnabled = false
            } label: {
                Label(
                    "Пройти обучение",
                    systemImage: "book.closed"
                )
            }

            Button(role: .destructive) {
                path.removeAll()
            } label: {
                Label(
                    "Выйти из модуля",
                    systemImage: "rectangle.portrait.and.arrow.right"
                )
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(ColorPalette.textPrimary)
        }
        #if DEBUG
            .confirmationDialog(
                "Демо-режим",
                isPresented: $isDemoConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button("Включить") {
                    demoModeToggle()
                }
            } message: {
                Text(
                    "Демо-режим заменит камеру на кнопки: ошибочный скан и скан нужного контейнера. Это удобно для прохождения флоу без реальной камеры. Доступен только в debug-сборке."
                )
            }
        #endif
    }

    @ViewBuilder
    private var scanner: some View {
        #if DEBUG
            if isDemoModeOn {
                demoControls
            } else {
                scannerView
            }
        #else
            scannerView
        #endif
    }

    private var scannerView: some View {
        ScannerView(
            isScanningEnabled: $isScanningEnabled,
            idleText: "Сканируйте контейнер",
            activeText: "Сканируем контейнер...",
            previewHeight: 400,
            onScan: { code in processScan(code) }
        )
    }

    #if DEBUG
        private var demoControls: some View {
            HStack(spacing: 12) {
                Button {
                    processScan(demoWrongContainerCode)
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
                    processScan(viewModel.container.id)
                } label: {
                    Text("Контейнер")
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
            .frame(height: 130)
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        ColorPalette.brandMuted.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1, dash: [6])
                    )
            }
        }

        private func demoButtonTapped() {
            if isDemoModeOn {
                demoModeToggle()
            } else {
                isDemoConfirmationPresented = true
            }
        }

        private func demoModeToggle() {
            isDemoModeOn.toggle()
            isScanningEnabled = false
        }
    #endif

    private func disableDemoMode() {
        #if DEBUG
            isDemoModeOn = false
        #endif
    }

    private var containerCard: some View {

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 24) {
                Image(systemName: "tray.full")
                    .font(.system(size: 40))
                VStack(alignment: .leading, spacing: 12) {
                    Text("Контейнер")
                    Text(viewModel.container.id)
                        .font(.system(size: 24, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(viewModel.container.location)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .foregroundStyle(ColorPalette.textPrimary)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                ColorPalette.surfaceAccent
            )
        )
    }

    private func processScan(_ code: String) {
        viewModel.processCode(code)

        if viewModel.lastError == nil {
            FeedbackService.playSuccess()
            path.append(.putaway(.task(task)))
        } else {
            FeedbackService.playError()
        }
    }
}

#Preview {
    @Previewable @State var path: [OperationType.WorkRoute] = []

    NavigationStack(path: $path) {
        PutawayContainerView(
            task: MockData.putawayTaskMock,
            path: $path
        )
    }
}
