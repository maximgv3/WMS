import SwiftUI
import UIKit

struct ReturnsTaskView: View {

    @AppStorage("isReturnsOnboardingComplete") private
        var isReturnsOnboardingComplete = false
    @State private var viewModel: ReturnsTaskViewModel
    @Binding private var path: [OperationType.WorkRoute]
    @State private var isScanningEnabled = false
    @State private var isOnboardingPresented = false
    @State private var pendingDecision: ReturnDecision?
    @State private var photoThumbnails: [Item.ID: Image] = [:]

    #if DEBUG
        @AppStorage("isReturnsDemoModeOn") private var isDemoModeOn = false
    #endif

    init(
        task: ReturnsTask,
        containers: ReturnsContainers,
        service: ReturnsTaskServiceProtocol,
        progressStore: ReturnsProgressStoreProtocol = ReturnsProgressStore(),
        path: Binding<[OperationType.WorkRoute]>
    ) {
        self._path = path
        self.viewModel = ReturnsTaskViewModel(
            task: task,
            containers: containers,
            service: service,
            progressStore: progressStore
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            ReturnsItemCard(returnItem: viewModel.currentItem)
            scanner
            containersRow
            content
        }
        .padding([.horizontal, .top], 16)
        .safeAreaInset(edge: .bottom) {
            ZStack {
                if isFinishAvailable {
                    PrimaryButton(
                        .commonFinishTask,
                        background: ColorPalette.success,
                        foreground: ColorPalette.textInverted,
                        isGlassy: true
                    ) {
                        path.append(.returns(.finish(viewModel.result)))
                    }
                    .padding(.horizontal, 16)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                }
            }
            .animation(
                .spring(response: 0.22, dampingFraction: 0.55),
                value: isFinishAvailable
            )
        }
        .background(ColorPalette.backgroundPrimary.ignoresSafeArea())
        .errorBanner(
            title: errorTitle,
            message: errorMessage
        )
        .fullScreenCover(item: $pendingDecision) { decision in
            CameraPickerView(hint: decision.photoHint) { shot in
                pendingDecision = nil
                guard let shot else { return }
                applyDecision(
                    decision,
                    photo: shot.data,
                    thumbnail: shot.thumbnail
                )
            }
            .ignoresSafeArea()
        }
        .task {
            restorePhotoThumbnails()
            await viewModel.preloadImages()
        }
        .onAppear {
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
            ToolbarItem(placement: .topBarLeading) {
                TaskProgressMenu(
                    doneCount: viewModel.checkedItemsCount,
                    totalCount: viewModel.allItemsCount
                ) {
                    if viewModel.checkedItemsCount > 0 {
                        Text(.returnsInspectedCount(viewModel.checkedItemsCount))
                    }
                    Text(.commonRemainingCount(viewModel.leftItems.count))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ReturnsTaskMenu(
                    isAllItemsChecked: viewModel.isAllItemsChecked,
                    onFinishEarly: {
                        withAnimation(.snappy) {
                            viewModel.clearCurrentItem()
                        }
                    },
                    onFinish: {
                        path.append(.returns(.finish(viewModel.result)))
                    },
                    onDemoModeChanged: {
                        isScanningEnabled = false
                    },
                    onTutorial: {
                        isReturnsOnboardingComplete = false
                        isOnboardingPresented = true
                        isScanningEnabled = false
                    },
                    onExit: {
                        path.removeAll()
                    }
                )
            }
        }
    }

    private var isFinishAvailable: Bool {
        viewModel.isAllItemsChecked && viewModel.currentItem == nil
    }

    private var errorText: String? {
        switch viewModel.lastError {
        case .notAnItem:
            return String(localized: .commonScanItemAction)
        case .itemNotInTask:
            return String(localized: .returnsThisItemIsNotInTheTask)
        case .decisionRequired:
            return String(localized: .returnsDecisionRequired)
        case .notAContainer:
            return String(localized: .returnsScanToteAction)
        case .containerAlreadyUsed:
            return String(localized: .returnsThisToteIsAlreadyInUse)
        case .wrongContainer, nil:
            return nil
        }
    }

    private var errorTitle: LocalizedStringResource {
        switch viewModel.lastError {
        case .notAContainer, .containerAlreadyUsed:
            .returnsCouldNotSwitchTheTote
        default:
            .returnsCouldNotInspectTheItem
        }
    }

    private var containersRow: some View {
        HStack(spacing: 8) {
            ForEach(ReturnContainerSlot.allCases) { slot in
                ReturnsContainerChip(
                    slot: slot,
                    code: viewModel.containers[slot],
                    isRebinding: isRebinding(slot)
                ) {
                    withAnimation(.snappy) {
                        viewModel.startRebinding(slot)
                    }
                }
            }
        }
    }

    private var errorMessage: Binding<String?> {
        Binding(
            get: { errorText },
            set: { if $0 == nil { viewModel.clearError() } }
        )
    }

    @ViewBuilder
    private var scanner: some View {
        #if DEBUG
            if isDemoModeOn {
                ReturnsDemoControls(
                    isRebindingSlot: isRebindingAnySlot,
                    itemCode: (viewModel.leftItems.first ?? viewModel.task.items.first)
                        .map { String($0.id) },
                    onScan: processScan
                )
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
            idleText: isRebindingAnySlot
                ? .returnsScanTotePrompt : .commonScanItemPrompt,
            activeText: isRebindingAnySlot
                ? .returnsScanningTote : .commonScanningItem,
            onScan: { code in processScan(code) }
        )
    }

    private var isRebindingAnySlot: Bool { viewModel.rebindingSlot != nil }

    private func isRebinding(_ slot: ReturnContainerSlot) -> Bool {
        viewModel.rebindingSlot == slot
    }

    private func disableDemoMode() {
        #if DEBUG
            isDemoModeOn = false
        #endif
    }

    private var isDecisionPending: Bool { viewModel.currentItem != nil }

    private var content: some View {
        ZStack(alignment: .top) {
            ReturnsItemsList(
                leftItems: viewModel.leftItems,
                checkedItems: viewModel.checkedItems,
                decisions: viewModel.decisions,
                photos: photoThumbnails
            )
                .opacity(isDecisionPending ? 0 : 1)
                .allowsHitTesting(!isDecisionPending)

            decisions
                .opacity(isDecisionPending ? 1 : 0)
                .offset(y: isDecisionPending ? 0 : 12)
                .allowsHitTesting(isDecisionPending)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var decisions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(.returnsChooseItemDecision)
                .font(.headline)
            ForEach(ReturnDecision.allCases) { decision in
                ReturnsDecisionButton(decision: decision) {
                    decisionTapped(decision)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func decisionTapped(_ decision: ReturnDecision) {
        #if DEBUG
            if isDemoModeOn && decision.requiresPhoto {
                guard let photo = demoPhoto else { return }
                applyDecision(
                    decision,
                    photo: photo.data,
                    thumbnail: photo.thumbnail
                )
                return
            }
        #endif

        if decision.requiresPhoto {
            pendingDecision = decision
        } else {
            applyDecision(decision, photo: nil)
        }
    }

    private func applyDecision(
        _ decision: ReturnDecision,
        photo: Data?,
        thumbnail: Image? = nil
    ) {
        if let id = viewModel.currentItem?.id {
            photoThumbnails[id] = thumbnail
        }
        withAnimation(.snappy) {
            viewModel.decide(decision, photo: photo)
        }
        FeedbackService.playSuccess()
    }

    private func restorePhotoThumbnails() {
        let thumbnailSize = CGSize(width: 96, height: 96)
        for (itemId, data) in viewModel.photos {
            guard let image = UIImage(data: data) else { continue }
            let thumbnail = image.preparingThumbnail(of: thumbnailSize) ?? image
            photoThumbnails[itemId] = Image(uiImage: thumbnail)
        }
    }

    #if DEBUG
        private var demoPhoto: CameraShot? {
            guard let image = UIImage(systemName: "photo"),
                let data = image.pngData()
            else {
                return nil
            }
            return CameraShot(data: data, thumbnail: Image(uiImage: image))
        }
    #endif

    private func processScan(_ code: String) {
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
        ReturnsTaskView(
            task: MockData.returnsTaskMock,
            containers: ReturnsContainers(
                good: "WMSCT770145",
                inspection: "WMSCT770238"
            ),
            service: ReturnsTaskServiceMock(),
            path: $path
        )
    }
}
