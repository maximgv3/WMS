import SwiftUI

struct PutawayTaskView: View {

    @AppStorage("isPutawayOnboardingComplete") private
        var isPutawayOnboardingComplete = false
    @State private var viewModel: PutawayTaskViewModel
    @Binding private var path: [OperationType.WorkRoute]
    @State var isScanningEnabled = false
    @State var isEarlyFinishPresented = false
    @State private var isOnboardingPresented = false

    #if DEBUG
        @AppStorage("isPutawayDemoModeOn") private var isDemoModeOn = false
        @State private var isDemoConfirmationPresented = false

        private let demoWrongCode = "0000000000"
    #endif

    init(
        task: PutawayTask,
        service: PutawayTaskServiceProtocol,
        path: Binding<[OperationType.WorkRoute]>
    ) {
        self.viewModel = PutawayTaskViewModel(task: task, service: service)
        self._path = path
    }

    var body: some View {
        VStack(spacing: 16) {
            storageCellCard
            scanner
            itemsList
        }
        .padding([.horizontal, .top], 16)
        .safeAreaInset(edge: .bottom) {
            ZStack {
                if viewModel.isAllItemsPlaced {
                    PrimaryButton(
                        .commonFinishTask,
                        background: ColorPalette.success,
                        foreground: ColorPalette.textInverted,
                        isGlassy: true
                    ) {
                        path.append(.putaway(.finish(viewModel.result)))
                    }
                    .padding(.horizontal, 16)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                }
            }
            .animation(
                .spring(response: 0.22, dampingFraction: 0.55),
                value: viewModel.isAllItemsPlaced
            )
        }
        .background(ColorPalette.backgroundPrimary.ignoresSafeArea())
        .errorBanner(
            title: .putawayCouldNotPutAwayTheItem,
            message: errorMessage,
            autoDismissAfter: errorAutoDismiss
        )
        .task {
            await viewModel.preloadImages()
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
            ToolbarItem(placement: .topBarLeading) {
                TaskProgressMenu(
                    doneCount: viewModel.placedItemsCount,
                    totalCount: viewModel.allItemsCount
                ) {
                    if viewModel.placedItemsCount > 0 {
                        Text(.putawayPlacedCount(viewModel.placedItemsCount))
                    }
                    Text(.putawayUnprocessedCount(viewModel.leftItems.count))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                exitMenu
            }
        }
    }

    private var isCellSelected: Bool { viewModel.currentCell != nil }
    private var listedItems: [Item] {
        isCellSelected ? viewModel.currentCellItems : viewModel.leftItems
    }

    private var errorText: String? {
        switch viewModel.lastError {
        case .notACell:
            return String(localized: .putawayScanABinFirst)
        case .notAnItem:
            return String(localized: .commonScanItemAction)
        case .itemNotInTask:
            return String(
                localized:
                    .putawayForeignItemConfirmation
            )
        case .cellIsFull:
            return String(localized: .putawayTheBinIsFull)
        case .wrongContainer, nil:
            return nil
        }
    }

    private var errorAutoDismiss: Duration {
        viewModel.lastError == .itemNotInTask ? .seconds(6) : .seconds(3)
    }

    private var errorMessage: Binding<String?> {
        Binding(
            get: { errorText },
            set: { if $0 == nil { viewModel.clearError() } }
        )
    }

    private var exitMenu: some View {
        Menu {
            if !viewModel.isAllItemsPlaced {
                Button {
                    viewModel.clearCurrentCell()
                    isEarlyFinishPresented = true
                } label: {
                    Label(
                        .commonFinishEarlyAction,
                        systemImage: "flag.checkered"
                    )
                }
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
                isPutawayOnboardingComplete = false
                isOnboardingPresented = true
                isScanningEnabled = false
            } label: {
                Label(
                    .commonViewTutorial,
                    systemImage: "book.closed"
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
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(ColorPalette.textPrimary)
        }
        .confirmationDialog(
            .commonEarlyFinishTitle,
            isPresented: $isEarlyFinishPresented,
            titleVisibility: .visible
        ) {
            Button(.commonFinish, role: .destructive) {
                path.append(.putaway(.finish(viewModel.result)))
            }
        } message: {
            Text(
                .putawayEarlyFinishWarning
            )
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
                    .putawayTaskDemoModeDescription
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
            idleText: isCellSelected
                ? .commonScanItemPrompt : .putawayScanABin,
            activeText: isCellSelected
                ? .commonScanningItem : .putawayScanningBin,
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

                if isCellSelected {
                    if let item = viewModel.leftItems.first {
                        demoPrimaryButton(.putawayPutAway) {
                            processScan(String(item.id))
                        }
                    }
                } else {
                    demoPrimaryButton(.commonBin) {
                        processScan(randomDemoCellCode())
                    }
                }
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

        private func demoPrimaryButton(
            _ title: LocalizedStringResource,
            action: @escaping () -> Void
        ) -> some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(ColorPalette.textInverted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ColorPalette.brandPrimary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
        }

        private func randomDemoCellCode() -> String {
            (0..<6)
                .map { _ in String(format: "%02d", Int.random(in: 1...99)) }
                .joined(separator: ".")
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

    private var storageCellCard: some View {
        ZStack {
            VStack(spacing: 12) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 40, weight: .light))
                Text(.putawayNoBinSelected)
                    .font(.system(size: 20, weight: .medium))
            }
            .foregroundStyle(ColorPalette.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 140)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        ColorPalette.textPrimary,
                        style: StrokeStyle(lineWidth: 2, dash: [6])
                    )
            }
            .opacity(isCellSelected ? 0 : 1)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(.commonBin)
                    Spacer()
                    changeCellButton
                        .padding(.horizontal, -6)
                }
                Text(
                    viewModel.currentCell?.id
                        ?? String(localized: .putawayNoBinSelected)
                )
                    .font(.system(size: 24, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                ProgressView(value: viewModel.currentCellProgress)
                    .tint(ColorPalette.accentPrimary)
                Text(
                    .commonProgress(viewModel.currentCellItemsCount, viewModel.task.cellCapacity)
                )
                .contentTransition(
                    .numericText(value: Double(viewModel.currentCellItemsCount))
                )
            }
            .padding(.horizontal, 16)
            .animation(.snappy, value: viewModel.currentCellItemsCount)
            .foregroundStyle(ColorPalette.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                    ColorPalette.surfaceAccent
                )
            )
            .opacity(isCellSelected ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .animation(.easeInOut(duration: 0.2), value: isCellSelected)
    }

    private var changeCellButton: some View {
        Button {
            viewModel.clearCurrentCell()
        } label: {
            Text(.putawaySwitchBin)
                .padding(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(ColorPalette.textPrimary, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassIfAvailable(
            shape: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
    }

    @ViewBuilder
    private var itemsList: some View {
        if listedItems.isEmpty {
            Text(isCellSelected ? .putawayThisBinIsEmpty : .putawayAllItemsPutAway)
                .foregroundStyle(ColorPalette.brandMuted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text(
                        isCellSelected
                            ? .putawayItemsInThisBin : .putawayRemainingToPutAway
                    )
                    .font(.headline)
                    ForEach(listedItems) { item in
                        itemRow(item: item)
                    }
                }
                .animation(.snappy, value: listedItems)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func itemRow(item: Item) -> some View {
        HStack(spacing: 12) {

            Group {
                if let imageUrl = item.imageUrl {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        itemImagePlaceholder
                    }
                } else {
                    itemImagePlaceholder
                }
            }
            .frame(width: 44, height: 44)
            Text(title(for: item))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text.itemId(item.id)
                .lineLimit(1)
                .layoutPriority(1)
                .monospacedDigit()
        }
    }

    private var itemImagePlaceholder: some View {
        Image(systemName: "photo")
            .font(.system(size: 22))
            .foregroundStyle(ColorPalette.textPrimary)
    }

    private func processScan(_ code: String) {
        viewModel.processCode(code)

        if viewModel.lastError == nil {
            FeedbackService.playSuccess()
        } else {
            FeedbackService.playError()
        }
    }

    private func title(for item: Item) -> String {
        guard let detail = item.size ?? item.color ?? item.brand else {
            return item.title
        }
        return item.title + ", " + detail
    }
}

#Preview {
    @Previewable @State var path: [OperationType.WorkRoute] = []

    NavigationStack(path: $path) {
        PutawayTaskView(
            task: MockData.putawayTaskMock,
            service: PutawayTaskServiceMock(),
            path: $path
        )
    }
}
