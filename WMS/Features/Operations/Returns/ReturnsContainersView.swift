import SwiftUI

struct ReturnsContainersView: View {

    @AppStorage("isReturnsOnboardingComplete") private
        var isReturnsOnboardingComplete = false
    @State private var viewModel: ReturnsContainersViewModel
    @Binding private var path: [OperationType.WorkRoute]
    @State private var isScanningEnabled = false
    @State private var isOnboardingPresented = false

    #if DEBUG
        @AppStorage("isReturnsDemoModeOn") private var isDemoModeOn = false
        @State private var isDemoConfirmationPresented = false

        private let demoWrongCode = "0000000000"
        private let demoSlotCodes: [ReturnContainerSlot: String] = [
            .good: "WMSCT770145",
            .inspection: "WMSCT770238",
        ]
    #endif

    private let task: ReturnsTask

    init(
        task: ReturnsTask,
        path: Binding<[OperationType.WorkRoute]>
    ) {
        self.task = task
        self.viewModel = ReturnsContainersViewModel(container: task.container)
        self._path = path
    }

    var body: some View {
        VStack(spacing: 16) {
            containerCard
            scanner
            Text(hint)
                .multilineTextAlignment(.center)
                .foregroundStyle(ColorPalette.brandMuted)
                .frame(maxWidth: .infinity, minHeight: 40)
            slots
            Spacer(minLength: 0)
        }
        .padding([.horizontal, .top], 16)
        .safeAreaInset(edge: .bottom) {
            ZStack {
                if let containers = viewModel.containers {
                    PrimaryButton(
                        "Начать проверку",
                        background: ColorPalette.success,
                        foreground: ColorPalette.textInverted,
                        isGlassy: true
                    ) {
                        path.append(.returns(.task(task, containers)))
                    }
                    .padding(.horizontal, 16)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                }
            }
            .animation(
                .spring(response: 0.22, dampingFraction: 0.55),
                value: viewModel.containers
            )
        }
        .background(ColorPalette.backgroundPrimary.ignoresSafeArea())
        .errorBanner(
            title: "Не удалось начать проверку",
            message: errorMessage
        )
        .onAppear {
            isOnboardingPresented = !isReturnsOnboardingComplete
            disableDemoMode()
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            OnboardingView(
                pages: OnboardingPages.Returns.pages,
                completionImage: .returnsOnboardingEnd
            ) {
                isReturnsOnboardingComplete = true
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                exitMenu
            }
        }
    }

    private var hint: String {
        guard viewModel.isContainerScanned else {
            return "Найдите тару с возвратами\nи отсканируйте её код"
        }
        switch viewModel.nextSlot {
        case .good:
            return "Отсканируйте тару, в которую\nбудете класть годный товар"
        case .inspection:
            return "Отсканируйте тару для товара,\nкоторый уйдёт на проверку"
        case nil:
            return "Тары привязаны, можно начинать"
        }
    }

    private var errorText: String? {
        switch viewModel.lastError {
        case .wrongContainer:
            return "Это не та тара"
        case .notAContainer:
            return "Отсканируйте тару"
        case .containerAlreadyUsed:
            return "Эта тара уже занята"
        case .notAnItem, .itemNotInTask, .decisionRequired, nil:
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
                isReturnsOnboardingComplete = false
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
                    "Демо-режим заменит камеру на кнопки: ошибочный скан и скан нужной тары. Это удобно для прохождения флоу без реальной камеры. Доступен только в debug-сборке."
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
            idleText: "Сканируйте тару",
            activeText: "Сканируем тару...",
            previewHeight: 240,
            onScan: { code in processScan(code) }
        )
    }

    #if DEBUG
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
                    processScan(demoNextCode)
                } label: {
                    Text("Тара")
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

        private var demoNextCode: String {
            guard viewModel.isContainerScanned else {
                return viewModel.container.id
            }
            guard let slot = viewModel.nextSlot else { return demoWrongCode }
            return demoSlotCodes[slot] ?? demoWrongCode
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
        HStack(spacing: 24) {
            Image(systemName: "shippingbox")
                .font(.system(size: 40))
            VStack(alignment: .leading, spacing: 12) {
                Text("Тара с возвратами")
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
            if viewModel.isContainerScanned {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(ColorPalette.success)
            }
        }
        .padding(.horizontal, 16)
        .foregroundStyle(ColorPalette.textPrimary)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                ColorPalette.accentPrimary.opacity(0.18)
            )
        )
    }

    private var slots: some View {
        VStack(spacing: 8) {
            ForEach(ReturnContainerSlot.allCases) { slot in
                slotRow(slot)
            }
        }
    }

    private func slotRow(_ slot: ReturnContainerSlot) -> some View {
        HStack(spacing: 12) {
            Image(systemName: slot.iconName)
                .font(.system(size: 22))
                .foregroundStyle(color(for: slot))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(slot.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(viewModel.boundContainers[slot] ?? "Тара не привязана")
                    .font(.system(size: 14))
                    .foregroundStyle(ColorPalette.brandMuted)
                    .monospacedDigit()
            }
            Spacer()

            if viewModel.boundContainers[slot] != nil {
                Image(systemName: "checkmark")
                    .foregroundStyle(ColorPalette.success)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                color(for: slot).opacity(0.12)
            )
        )
        .foregroundStyle(ColorPalette.textPrimary)
    }

    private func color(for slot: ReturnContainerSlot) -> Color {
        switch slot {
        case .good:
            ColorPalette.success
        case .inspection:
            ColorPalette.error
        }
    }

    private func processScan(_ code: String) {
        guard !viewModel.isContainerScanned || viewModel.nextSlot != nil else {
            return
        }

        withAnimation(.snappy) {
            viewModel.processCode(code)
        }

        if viewModel.lastError == nil {
            FeedbackService.playSuccess()
        } else {
            FeedbackService.playError()
        }
    }
}

#Preview {
    @Previewable @State var path: [OperationType.WorkRoute] = []

    NavigationStack(path: $path) {
        ReturnsContainersView(
            task: MockData.returnsTaskMock,
            path: $path
        )
    }
}
