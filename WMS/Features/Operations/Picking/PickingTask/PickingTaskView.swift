import SwiftUI

struct PickingTaskView: View {
    // MARK: - State
    @AppStorage("isPickingOnboardingComplete") private
        var isPickingOnboardingComplete = false
    @State private var viewModel: PickingTaskViewModel
    @Binding private var path: [OperationType.WorkRoute]
    @State private var isSkipConfirmationPresented = false
    @State private var isOnboardingPresented = false
    @State private var isReplacementModeOn = false
    @State private var hasNavigatedToFinish = false

    #if DEBUG
        @State private var isDemoModeOn = false
        @State private var isDemoConfirmationPresented = false
    #endif

    // Error banner
    @State private var banner = ToolbarErrorBanner()

    // Scanner state
    @State private var isScanningEnabled = false

    // MARK: - Init
    init(
        pickingTask: PickingTask,
        pickingTaskService: PickingTaskServiceProtocol,
        progressStore: PickingProgressStoreProtocol = PickingProgressStore(),
        path: Binding<[OperationType.WorkRoute]>
    ) {
        self.viewModel = PickingTaskViewModel(
            pickingTask: pickingTask,
            pickingTaskService: pickingTaskService,
            progressStore: progressStore
        )
        self._path = path
    }

    // MARK: - Computed Properties
    private var currentItem: Item? { viewModel.currentItem }
    private var currentItemPriceText: String {
        guard let currentItem else { return "—" }
        return currentItem.price.formatted(
            .currency(code: "RUB")
                .locale(.current)
                .precision(.fractionLength(0))
        )
    }
    private var scannerIdleText: LocalizedStringResource {
        isReplacementModeOn
            ? .pickingScanAReplacement
            : .pickingPressAndHoldToScan
    }
    private var scannerActiveText: LocalizedStringResource {
        isReplacementModeOn ? .pickingScanningReplacement : .pickingScanning
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            if let currentItem {
                ScrollView {
                    VStack {
                        ItemImage(url: currentItem.imageUrl)
                        VStack(spacing: 6) {
                            Text(currentItem.title)
                                .font(.system(size: 22, weight: .bold))
                            Text.itemId(currentItem.id, base: .medium)
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
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary.ignoresSafeArea())
        .task {
            await viewModel.preloadImages()
        }
        .task {
            await Task.yield()
            navigateToFinishIfNeeded()
        }
        .onAppear {
            isOnboardingPresented = !isPickingOnboardingComplete
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            OnboardingView(
                pages: OnboardingPages.Picking.pages,
                completionImage: .pickingOnboardingEnd
            ) {
                isPickingOnboardingComplete = true
            }
        }
        .alert(.pickingAreYouSure, isPresented: $isSkipConfirmationPresented) {
            Button(.pickingCancel, role: .cancel) {}

            Button(.pickingSkip, role: .destructive) {
                viewModel.skipCurrentItem()
            }
        } message: {
            Text(
                .pickingMissingItemWarning(currentItemPriceText)
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
                navigateToFinishIfNeeded()
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

    private func navigateToFinishIfNeeded() {
        guard viewModel.isPickingEnded, !hasNavigatedToFinish else { return }
        hasNavigatedToFinish = true
        path.append(
            .picking(
                .finish(
                    PickingResult(
                        collectedItems: viewModel.collectedItems,
                        skippedItems: viewModel.skippedItems,
                        replacements: viewModel.replacements
                    )
                )
            )
        )
    }

    // MARK: - Progress
    private var progressMenu: some View {
        TaskProgressMenu(
            doneCount: viewModel.collectedItemsCount
                + viewModel.skippedItemsCount,
            totalCount: viewModel.allItemsCount
        ) {
            Text(
                .pickingProgress(viewModel.collectedItemsCount, viewModel.allItemsCount)
            )
            if viewModel.skippedItemsCount > 0 {
                Text(.commonSkippedCount(viewModel.skippedItemsCount))
            }
        }
    }

    private var topMenu: some View {
        Menu {
            Button {
                isReplacementModeOn.toggle()
                disableDemoMode()
                isScanningEnabled = false
            } label: {
                Label(
                    .pickingPickReplacement,
                    systemImage: "arrow.triangle.2.circlepath"
                )
            }
            #if DEBUG
                Button {
                    demoButtonTapped()
                } label: {
                    Label(
                        .commonDemoMode,
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
                    .commonViewTutorial,
                    systemImage: "book.closed"
                )
            }
            Button {
                isSkipConfirmationPresented = true
            } label: {
                Label(
                    .pickingSkipItem,
                    systemImage: "xmark.bin"
                )
            }
            Button(role: .destructive) {
                path.removeAll()
            } label: {
                Label(
                    .commonExitOperation,
                    systemImage: "rectangle.portrait.and.arrow.right"
                )
            }
        } label: {
            exitMenuIcon
        }
        #if DEBUG
            .confirmationDialog(
                .commonDemoMode,
                isPresented: $isDemoConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button(.commonEnable) {
                    demoModeToggle()
                }
            } message: {
                Text(
                    .pickingDemoModeDescription
                )
            }
        #endif
    }

    private var exitMenuIcon: some View {
        Image(systemName: "ellipsis.circle")
            .foregroundStyle(ColorPalette.textPrimary)
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
            FeedbackService.playSuccess()
        } catch {
            FeedbackService.playError()
            showError(error)
        }
    }

    private func tryToCollect(scannedCode: String) {
        do {
            try viewModel.tryToCollect(scannedCode: scannedCode)
            FeedbackService.playSuccess()
        } catch {
            FeedbackService.playError()
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
                FeedbackService.playSuccess()
            } catch {
                FeedbackService.playError()
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
            return String(localized: .pickingWrongItem)
        case .alreadyCollected:
            return String(localized: .pickingThisBarcodeHasAlreadyBeenPicked)
        case .cantUseForReplacement:
            return String(localized: .pickingThisReplacementIsNotAllowed)
        }
    }

    @ViewBuilder
    private func errorBanner(_ message: String) -> some View {
        let label = Text(message)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(ColorPalette.textInverted)
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
                        Text(.pickingPick)
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
            }
        }
    #endif

    @ViewBuilder
    private var scannerCollectButton: some View {
        if currentItem != nil {
            ScannerView(
                isScanningEnabled: $isScanningEnabled,
                idleText: scannerIdleText,
                activeText: scannerActiveText,
                onScan: { scannedCode in
                    if isReplacementModeOn {
                        tryToReplace(scannedCode: scannedCode)
                    } else {
                        tryToCollect(scannedCode: scannedCode)
                    }
                }
            )
        }
    }

}

// MARK: - Preview
#Preview {
    @Previewable @State var path: [OperationType.WorkRoute] = []

    NavigationStack(path: $path) {
        PickingTaskView(
            pickingTask: PickingTask(allItems: MockData.itemsMock),
            pickingTaskService: PickingListServiceMock(),
            path: $path
        )
    }
}
