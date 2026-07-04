import SwiftUI

struct PickingTaskView: View {
    // MARK: - State
    @AppStorage("isPickingOnboardingComplete") private var isPickingOnboardingComplete = false
    @State private var viewModel: PickingTaskViewModel
    @Binding private var path: [PickingRoute]
    @State private var isSkipConfirmationPresented = false
    @State private var isOnboardingPresented = false
    @State private var isReplacementModeOn = false

    #if DEBUG
    @State private var isDemoModeOn = false
    @State private var isDemoConfirmationPresented = false
    #endif

    // Error banner
    @State private var banner = ToolbarErrorBanner()

    // Scanner state
    @State private var isScanningEnabled = false
    private let scannerPreviewHeight: CGFloat = 130

    // MARK: - Init
    init(
        pickingTask: PickingTask,
        pickingTaskService: PickingTaskServiceProtocol,
        path: Binding<[PickingRoute]>
    ) {
        self.viewModel = PickingTaskViewModel(
            pickingTask: pickingTask,
            pickingTaskService: pickingTaskService
        )
        self._path = path
    }

    // MARK: - Computed Properties
    private var currentItem: Item? { viewModel.currentItem }
    private var currentItemPriceText: String {
        guard let currentItem else { return "—" }
        return String(format: "%.0f₽", currentItem.price)
    }
    private var scannerIdleText: String {
        isReplacementModeOn
            ? "Отсканируйте замену"
            : "Удерживайте для сканирования"
    }
    private var scannerActiveText: String {
        isReplacementModeOn ? "Сканирование замены..." : "Сканирование..."
    }

    // MARK: - Body
    var body: some View {
        Group {
            if let currentItem {
                ScrollView {
                    VStack {
                        ItemImage(url: currentItem.imageUrl)
                        VStack(spacing: 6) {
                            Text(currentItem.title)
                                .font(.system(size: 22, weight: .bold))
                            highlightedIdText(currentItem.id)
                                .font(.system(size: 27))
                        }
                        collectButton
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                        ItemInfoTable(item: currentItem)
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 24)
                }
                .padding(.top, -12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await viewModel.preloadImages()
        }
        .onAppear {
            isOnboardingPresented = !isPickingOnboardingComplete
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            PickingOnboardingView()
        }
        .alert("Уверены?", isPresented: $isSkipConfirmationPresented) {
            Button("Отмена", role: .cancel) {}

            Button("Пропустить", role: .destructive) {
                viewModel.skipCurrentItem()
            }
        } message: {
            Text(
                "Информация о потерянном товаре будет передана руководителю. Стоимость товара: \(currentItemPriceText)"
            )
        }
        .onDisappear {
            banner.reset()
            isScanningEnabled = false
            isReplacementModeOn = false
            disableDemoMode()
        }
        .onChange(of: viewModel.isPickingEnded) { _, newValue in
            if newValue {
                path.append(
                    .finish(
                        PickingResult(
                            collectedItems: viewModel.collectedItems,
                            skippedItems: viewModel.skippedItems,
                            replacements: viewModel.replacements
                        )
                    )
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if banner.isPresented {
                ToolbarItem(placement: .principal) {
                    errorBanner(banner.message ?? "")
                        .scaleEffect(
                            banner.isVisible
                                ? (banner.isPulsing ? 1.08 : 1) : 0.96
                        )
                        .opacity(
                            banner.isVisible
                                ? (banner.isPulsing ? 0.65 : 1) : 0
                        )
                        .animation(
                            .easeInOut(duration: 0.18),
                            value: banner.isVisible
                        )
                        .animation(
                            .spring(response: 0.22, dampingFraction: 0.55),
                            value: banner.isPulsing
                        )
                        .allowsHitTesting(banner.isVisible)
                }
            }
            if banner.areSideItemsPresented {
                ToolbarItem(placement: .topBarLeading) {
                    progressMenu
                        .opacity(banner.areSideItemsVisible ? 1 : 0)
                        .scaleEffect(banner.areSideItemsVisible ? 1 : 0.92)
                        .animation(
                            .easeInOut(duration: 0.18),
                            value: banner.areSideItemsVisible
                        )
                        .allowsHitTesting(banner.areSideItemsVisible)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    topMenu
                        .opacity(banner.areSideItemsVisible ? 1 : 0)
                        .scaleEffect(banner.areSideItemsVisible ? 1 : 0.92)
                        .animation(
                            .easeInOut(duration: 0.18),
                            value: banner.areSideItemsVisible
                        )
                        .allowsHitTesting(banner.areSideItemsVisible)
                }
            }
        }
    }

    // MARK: - Item Info
    private func highlightedIdText(_ id: Int) -> Text {
        let idString = String(id)
        let prefix = String(idString.dropLast(4))
        let suffix = String(idString.suffix(4))
        return Text(prefix).fontWeight(.medium)
            + Text(suffix).fontWeight(.heavy)
    }

    // MARK: - Progress
    private var progressMenu: PickingProgressMenu {
        PickingProgressMenu(
            totalCount: viewModel.allItemsCount,
            collectedCount: viewModel.collectedItemsCount,
            skippedCount: viewModel.skippedItemsCount
        )
    }

    private var topMenu: some View {
        Menu {
            Button {
                isReplacementModeOn.toggle()
                disableDemoMode()
                isScanningEnabled = false
            } label: {
                Label(
                    "Собрать замену",
                    systemImage: "arrow.triangle.2.circlepath"
                )
            }
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
                isPickingOnboardingComplete = false
                isOnboardingPresented = true
                isReplacementModeOn = false
                isScanningEnabled = false
                disableDemoMode()
            } label: {
                Label(
                    "Пройти обучение",
                    systemImage: "book.closed"
                )
            }
            Button {
                isSkipConfirmationPresented = true
            } label: {
                Label(
                    "Пропустить товар",
                    systemImage: "xmark.bin"
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
            exitMenuIcon
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
            Text("Демо-режим заменит камеру на две кнопки: ошибочный скан и успешную сборку товара. Это удобно для демонстрации функционала без использования реальной камеры. Доступен только в debug-сборке.")
        }
        #endif
    }

    private var exitMenuIcon: some View {
        Image(systemName: "ellipsis.circle")
            .foregroundStyle(ColorPalette.brandPrimary)
    }

    #if DEBUG
    private func demoButtonTapped() {
        if isDemoModeOn {
            demoModeToggle()
        } else {
            isDemoConfirmationPresented = true
        }
    }
    private func demoModeToggle() {
        isDemoModeOn.toggle()
        isReplacementModeOn = false
        isScanningEnabled = false
    }
    #endif

    private func disableDemoMode() {
        #if DEBUG
        isDemoModeOn = false
        #endif
    }

    // MARK: - Actions
    private func tryToCollect(itemId: Int) {
        do {
            try viewModel.tryToCollect(itemId: itemId)
            SoundFeedback.playSuccess()
        } catch {
            SoundFeedback.playError()
            showError(error)
        }
    }

    private func tryToCollect(scannedCode: String) {
        do {
            try viewModel.tryToCollect(scannedCode: scannedCode)
            SoundFeedback.playSuccess()
        } catch {
            SoundFeedback.playError()
            showError(error)
        }
    }

    private func tryToReplace(scannedCode: String) {
        Task {
            do {
                guard let replacementId = Int(scannedCode) else {
                    throw PickingTaskError.wrongId
                }

                try await viewModel.tryToReplace(replacementId: replacementId)
                isReplacementModeOn = false
                SoundFeedback.playSuccess()
            } catch {
                SoundFeedback.playError()
                showError(error)
            }
        }
    }

    // MARK: - Error Banner
    private func showError(_ error: Error) {
        banner.show(message: message(for: error))
    }

    private func message(for error: Error) -> String {
        guard let pickingError = error as? PickingTaskError else {
            return error.localizedDescription
        }
        switch pickingError {
        case .wrongId:
            return "Это не тот товар"
        case .alreadyCollected:
            return "Этот ШК уже собран"
        case .cantUseForReplacement:
            return "Замена не подходит"
        }
    }

    @ViewBuilder
    private func errorBanner(_ message: String) -> some View {
        let label = Text(message)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(ColorPalette.surfacePrimary)
            .lineLimit(1)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)

        if #available(iOS 26.0, *) {
            label.glassEffect(.regular.tint(ColorPalette.error), in: Capsule())
        } else {
            label
                .background(ColorPalette.error)
                .clipShape(Capsule())
        }
    }

    // MARK: - Bottom Controls
    @ViewBuilder
    private var collectButton: some View {
        #if DEBUG
        if isDemoModeOn {
            demoCollectButtons
        } else {
            scannerCollectButton
        }
        #else
        scannerCollectButton
        #endif
    }

    #if DEBUG
    private var demoCollectButtons: some View {
        HStack(spacing: 12) {
            Button {
                tryToCollect(itemId: -1)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(ColorPalette.error)
                    .frame(width: 56, height: 56)
                    .background(ColorPalette.error.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            if let currentItem {
                Button {
                    tryToCollect(itemId: currentItem.id)
                } label: {
                    Text("Собрать")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(ColorPalette.surfacePrimary)
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
        }
    }
    #endif

    @ViewBuilder
    private var scannerCollectButton: some View {
        if currentItem != nil {
            ScannerPreviewView(
                scanAreaSize: nil,
                isScanningEnabled: isScanningEnabled,
                onScan: { scannedCode in
                    if isReplacementModeOn {
                        tryToReplace(scannedCode: scannedCode)
                    } else {
                        tryToCollect(scannedCode: scannedCode)
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .frame(height: scannerPreviewHeight)
            .clipShape(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        isScanningEnabled
                            ? ColorPalette.accentPrimary
                            : ColorPalette.brandMuted.opacity(0.35),
                        lineWidth: isScanningEnabled ? 3 : 1
                    )
            }
            .overlay {
                HStack(spacing: 10) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(width: 24)
                        .padding(.leading, 10)

                    Text(
                        isScanningEnabled
                            ? scannerActiveText : scannerIdleText
                    )
                    .font(.system(size: 18, weight: .bold))
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 10)
                .foregroundStyle(ColorPalette.surfacePrimary)
                .opacity(isScanningEnabled ? 0.35 : 0.85)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isScanningEnabled = true
                    }
                    .onEnded { _ in
                        isScanningEnabled = false
                    }
            )
        }
    }

}

// MARK: - Preview
#Preview {
    @Previewable @State var path: [PickingRoute] = []

    NavigationStack(path: $path) {
        PickingTaskView(
            pickingTask: PickingTask(allItems: MockData.itemsMock),
            pickingTaskService: PickingListServiceMock(),
            path: $path
        )
    }
}
