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

    // MARK: - Init
    init(pickingTask: PickingTask, path: Binding<[PickingRoute]>) {
        self.viewModel = PickingTaskViewModel(pickingTask: pickingTask)
        self._path = path
    }

    // MARK: - Computed Properties
    private var currentItem: Item? { viewModel.currentItem }

    private var progressPercentage: Double {
        guard viewModel.allItemsCount > 0 else { return 1 }
        return Double(viewModel.collectedItemsCount) / Double(viewModel.allItemsCount)
    }

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
                        itemInfoTable(for: currentItem)
                            .padding(.top, 8)
                        progress
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 110)
                }
                .padding(.top, -12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            collectButton
                .padding(.horizontal, 24)
        }
        .task {
            await viewModel.preloadImages()
        }
        .onDisappear {
            errorDismissTask?.cancel()
            isErrorBannerVisible = false
            isErrorToolbarPresented = false
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
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
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
                        .foregroundStyle(ColorPalette.brandPrimary)
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
    private var progress: some View {
        VStack {
            Text(
                "Собрано \(viewModel.collectedItemsCount) из \(viewModel.allItemsCount)"
            )
            ProgressView(value: progressPercentage)
                .tint(ColorPalette.accentPrimary)
                .animation(
                    .easeInOut(duration: 0.25),
                    value: progressPercentage
                )
        }
    }

    // MARK: - Actions
    private func tryToCollect(itemId: Int) {
        do {
            try viewModel.tryToCollect(itemId: itemId)
        } catch {
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
        isErrorToolbarPresented = true
        isErrorBannerVisible = false

        Task {
            try? await Task.sleep(for: .milliseconds(50))
            guard !Task.isCancelled else { return }
            await MainActor.run {
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
        if let currentItem {
            HStack(spacing: 12) {
                // TODO: Replace with scanner input.
                Button {
                    tryToCollect(itemId: -1)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 64, height: 60)
                }
                .buttonStyle(.borderedProminent)
                .tint(ColorPalette.error)
                .foregroundStyle(ColorPalette.surfacePrimary)

                Button {
                    tryToCollect(itemId: currentItem.id)
                } label: {
                    Text("Собрать")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(.borderedProminent)
                .tint(ColorPalette.accentPrimary)
                .foregroundStyle(ColorPalette.brandPrimary)
            }
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
