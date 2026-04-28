import SwiftUI

struct PickingTaskView: View {
    @State private var viewModel: PickingTaskViewModel
    @Binding private var path: [PickingRoute]
    @State private var errorMessage: String?
    private var isPickingEnded: Bool { viewModel.isPickingEnded }
    init(pickingTask: PickingTask, path: Binding<[PickingRoute]>) {
        self.viewModel = PickingTaskViewModel(pickingTask: pickingTask)
        self._path = path
    }
    private var currentItem: Item? { viewModel.currentItem }
    
    private var progressPercentage: Double { Double(viewModel.collectedItemsCount) / Double(viewModel.allItemsCount) }
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
                    .padding(.top, .zero)
                    .padding(.bottom, 110)
                }
                .padding(.top, -12)
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            collectButton
                .padding(.horizontal, 24)
        }
        .overlay(alignment: .top) {
            if let errorMessage {
                errorBanner(errorMessage)
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: errorMessage)
        .task {
            await viewModel.preloadImages()
        }
        .onChange(of: isPickingEnded) { _, newValue in
            if newValue {
                path.append(.finish(viewModel.collectedItems))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        path.removeAll()
                    } label: {
                        Label("Выйти из модуля", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
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
    
    private func highlightedIdText(_ id: Int) -> Text {
        let idString = String(id)
        let prefix = String(idString.dropLast(4))
        let suffix = String(idString.suffix(4))
        return Text(prefix).fontWeight(.medium) + Text(suffix).fontWeight(.heavy)
    }

    private func itemInfoTable(for item: Item) -> some View {
        VStack(spacing: 0) {
            infoRow(title: "Ячейка", value: item.placement ?? "—", isPrimary: true)
            infoRow(title: "Размер", value: item.size ?? "—")
            infoRow(title: "Цвет", value: item.color ?? "—")
            infoRow(title: "Артикул", value: item.article)
            infoRow(title: "Бренд", value: item.brand ?? "—")
        }
        .padding(.horizontal, 16)
    }

    private func infoRow(title: String, value: String, isPrimary: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(size: isPrimary ? 21 : 19, weight: isPrimary ? .semibold : .regular))
                .foregroundStyle(isPrimary ? .primary : .secondary)
            Spacer()
            Text(value)
                .font(.system(size: isPrimary ? 22 : 19, weight: isPrimary ? .bold : .medium))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, isPrimary ? 14 : 12)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var progress: some View {
        VStack {
            Text("Собрано \(viewModel.collectedItemsCount) из \(viewModel.allItemsCount)")
            ProgressView(value: progressPercentage)
                .tint(ColorPalette.accentPrimary)
                .animation(.easeInOut(duration: 0.25), value: progressPercentage)
        }
    }
    
    private func collect(itemId: Int) {
        do {
            try viewModel.tryToCollect(itemId: itemId)
        } catch {
            showError(error)
        }
    }

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

        Task {
            try? await Task.sleep(for: .seconds(2))
            errorMessage = nil
        }
    }
    
    @ViewBuilder
    private var collectButton: some View {
        if let currentItem {
            HStack(spacing: 12) {
                Button {
                    collect(itemId: -1)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: 64, height: 60)
                }
                .buttonStyle(.borderedProminent)
                .tint(ColorPalette.error)
                .foregroundStyle(ColorPalette.surfacePrimary)

                Button {
                    collect(itemId: currentItem.id)
                } label: {
                    Text("Собрать")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(.borderedProminent)
                .tint(ColorPalette.accentPrimary)
                .foregroundStyle(ColorPalette.brandPrimary)
            }
        } else {
            EmptyView()
        }
    }
    
    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(ColorPalette.surfacePrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(ColorPalette.error)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    private var noImage: some View {
        Image(systemName: "photo.badge.exclamationmark")
            .font(.system(size: 44))
            .foregroundStyle(ColorPalette.brandMuted)
    }
}

#Preview {
    @Previewable @State var path: [PickingRoute] = []

    NavigationStack(path: $path) {
        PickingTaskView(pickingTask: PickingTask(allItems: MockData().mockItems), path: $path)
    }
}
