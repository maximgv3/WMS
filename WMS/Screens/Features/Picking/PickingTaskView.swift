import SwiftUI

struct PickingTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PickingTaskViewModel
    @Binding private var path: [PickingRoute]
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
                    .padding(.top, 12)
                    .padding(.bottom, 110)
                }
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            collectButton
                .padding(.horizontal, 24)
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
        .frame(height: 280)
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
    
    @ViewBuilder
    private var collectButton: some View {
        if let currentItem {
            Button {
                try? viewModel.tryToCollect(itemId: currentItem.id)
            } label: {
                Text("Собрать")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
            .buttonStyle(.borderedProminent)
            .tint(ColorPalette.accentPrimary)
            .foregroundStyle(ColorPalette.brandPrimary)
        } else {
            EmptyView()
        }
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
