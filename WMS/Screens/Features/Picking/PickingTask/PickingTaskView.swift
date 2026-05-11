import AudioToolbox
import SwiftUI

struct PickingTaskView: View {
    // MARK: - State
    @State private var viewModel: PickingTaskViewModel
    @Binding private var path: [PickingRoute]

    // Error banner state
    @State private var errorMessage: String?
    @State private var errorDismissTask: Task<Void, Never>?
    @State private var isErrorToolbarPresented = false
    @State private var isErrorBannerVisible = false
    @State private var isErrorBannerPulsing = false
    @State private var areToolbarSideItemsPresented = true
    @State private var areToolbarSideItemsVisible = true

    // Scanner state
    @State private var isScanningEnabled = false
    private let scannerPreviewHeight: CGFloat = 130

    // MARK: - Init
    init(pickingTask: PickingTask, path: Binding<[PickingRoute]>) {
        self.viewModel = PickingTaskViewModel(pickingTask: pickingTask)
        self._path = path
    }

    // MARK: - Computed Properties
    private var currentItem: Item? { viewModel.currentItem }

    // MARK: - Body
    var body: some View {
        Group {
            if let currentItem {
                ScrollView {
                    VStack {
                        image
                        VStack(spacing: 6) {
                            Text(currentItem.title)
                                .font(.system(size: 22, weight: .bold))
                            highlightedIdText(currentItem.id)
                                .font(.system(size: 27))
                        }
                        collectButton
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                        itemInfoTable(for: currentItem)
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
        .onDisappear {
            errorDismissTask?.cancel()
            isErrorBannerVisible = false
            isErrorToolbarPresented = false
            areToolbarSideItemsPresented = true
            areToolbarSideItemsVisible = true
            isScanningEnabled = false
        }
        .onChange(of: viewModel.isPickingEnded) { _, newValue in
            if newValue {
                path.append(.finish(viewModel.collectedItems))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if isErrorToolbarPresented {
                ToolbarItem(placement: .principal) {
                    errorBanner(errorMessage ?? "Это не тот товар")
                        .scaleEffect(
                            isErrorBannerVisible
                                ? (isErrorBannerPulsing ? 1.08 : 1) : 0.96
                        )
                        .opacity(
                            isErrorBannerVisible
                                ? (isErrorBannerPulsing ? 0.65 : 1) : 0
                        )
                        .animation(
                            .easeInOut(duration: 0.18),
                            value: isErrorBannerVisible
                        )
                        .animation(
                            .spring(response: 0.22, dampingFraction: 0.55),
                            value: isErrorBannerPulsing
                        )
                        .allowsHitTesting(isErrorBannerVisible)
                }
            }
            if areToolbarSideItemsPresented {
                ToolbarItem(placement: .topBarLeading) {
                    progressMenu
                        .opacity(areToolbarSideItemsVisible ? 1 : 0)
                        .scaleEffect(areToolbarSideItemsVisible ? 1 : 0.92)
                        .animation(
                            .easeInOut(duration: 0.18),
                            value: areToolbarSideItemsVisible
                        )
                        .allowsHitTesting(areToolbarSideItemsVisible)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    topMenu
                        .opacity(areToolbarSideItemsVisible ? 1 : 0)
                        .scaleEffect(areToolbarSideItemsVisible ? 1 : 0.92)
                        .animation(
                            .easeInOut(duration: 0.18),
                            value: areToolbarSideItemsVisible
                        )
                        .allowsHitTesting(areToolbarSideItemsVisible)
                }
            }
        }
    }

    // MARK: - Image
    @ViewBuilder
    private var image: some View {
        Group {
            if let url = currentItem?.imageUrl {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .empty:
                        ProgressView()
                            .tint(ColorPalette.brandSecondary)
                            .controlSize(.large)
                    case .failure:
                        noImage
                    @unknown default:
                        noImage
                    }
                }
                .id(url)
            } else {
                noImage
            }
        }
        .frame(height: 240)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Item Info
    private func highlightedIdText(_ id: Int) -> Text {
        let idString = String(id)
        let prefix = String(idString.dropLast(4))
        let suffix = String(idString.suffix(4))
        return Text(prefix).fontWeight(.medium)
            + Text(suffix).fontWeight(.heavy)
    }

    private func itemInfoTable(for item: Item) -> some View {
        VStack(spacing: 0) {
            infoRow(
                title: "Ячейка",
                value: item.placement ?? "—",
                isPrimary: true
            )
            infoRow(title: "Размер", value: item.size ?? "—")
            infoRow(title: "Цвет", value: item.color ?? "—")
            infoRow(title: "Артикул", value: item.article)
            infoRow(title: "Бренд", value: item.brand ?? "—")
        }
        .padding(.horizontal, 16)
    }

    private func infoRow(title: String, value: String, isPrimary: Bool = false)
        -> some View
    {
        HStack {
            Text(title)
                .font(
                    .system(
                        size: isPrimary ? 21 : 19,
                        weight: isPrimary ? .semibold : .regular
                    )
                )
                .foregroundStyle(isPrimary ? .primary : .secondary)
            Spacer()
            Text(value)
                .font(
                    .system(
                        size: isPrimary ? 22 : 19,
                        weight: isPrimary ? .bold : .medium
                    )
                )
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, isPrimary ? 14 : 12)
        .overlay(alignment: .bottom) {
            Divider()
        }
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
                viewModel.skipCurrentItem()
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
    }

    private var exitMenuIcon: some View {
        Image(systemName: "ellipsis.circle")
            .foregroundStyle(ColorPalette.brandPrimary)
    }

    // MARK: - Actions
    private func tryToCollect(itemId: Int) {
        do {
            try viewModel.tryToCollect(itemId: itemId)
            PickingSoundFeedback.playSuccess()
        } catch {
            PickingSoundFeedback.playError()
            showError(error)
        }
    }

    private func tryToCollect(scannedCode: String) {
        do {
            try viewModel.tryToCollect(scannedCode: scannedCode)
            PickingSoundFeedback.playSuccess()
        } catch {
            PickingSoundFeedback.playError()
            showError(error)
        }
    }

    // MARK: - Error Banner
    private func showError(_ error: Error) {
        if let pickingError = error as? PickingTaskError {
            switch pickingError {
            case .wrongId:
                errorMessage = "Это не тот товар"
            case .alreadyCollected:
                errorMessage = "Этот товар уже собран"
            }
        } else {
            errorMessage = error.localizedDescription
        }
        errorDismissTask?.cancel()
        areToolbarSideItemsVisible = false
        isErrorToolbarPresented = true
        isErrorBannerVisible = false

        Task {
            try? await Task.sleep(for: .milliseconds(50))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                areToolbarSideItemsPresented = false
                isErrorBannerVisible = true
                pulseErrorBanner()
            }
        }

        errorDismissTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await hideErrorBanner()
        }
    }

    private func pulseErrorBanner() {
        isErrorBannerPulsing = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(180))
            isErrorBannerPulsing = false
        }
    }

    @MainActor
    private func hideErrorBanner() async {
        isErrorBannerVisible = false

        try? await Task.sleep(for: .milliseconds(180))
        guard !Task.isCancelled else { return }

        errorMessage = nil
        isErrorToolbarPresented = false
        areToolbarSideItemsPresented = true

        try? await Task.sleep(for: .milliseconds(50))
        guard !Task.isCancelled else { return }

        areToolbarSideItemsVisible = true
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(ColorPalette.surfacePrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(ColorPalette.error)
            .clipShape(Capsule())
            .lineLimit(1)
    }

    // MARK: - Bottom Controls
    @ViewBuilder
    private var collectButton: some View {
        if currentItem != nil {
            ScannerPreviewView(
                scanAreaSize: nil,
                isScanningEnabled: isScanningEnabled,
                onScan: { scannedCode in
                    tryToCollect(scannedCode: scannedCode)
                }
            )
            .frame(maxWidth: .infinity)
            .frame(height: scannerPreviewHeight)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
                        .font(.system(size: 22, weight: .semibold))
                    Text(
                        isScanningEnabled
                            ? "Сканирование..." : "Удерживайте для сканирования"
                    )
                    .font(.system(size: 20, weight: .bold))
                }
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

    // MARK: - Placeholders
    private var noImage: some View {
        Image(systemName: "photo.badge.exclamationmark")
            .font(.system(size: 44))
            .foregroundStyle(ColorPalette.brandMuted)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var path: [PickingRoute] = []

    NavigationStack(path: $path) {
        PickingTaskView(
            pickingTask: PickingTask(allItems: MockData().mockItems),
            path: $path
        )
    }
}

// MARK: - Sound Feedback
private enum PickingSoundFeedback {
    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playError() {
        AudioServicesPlaySystemSound(1051)
    }
}
