import SwiftUI

struct PutawayTaskView: View {

    @State private var viewModel: PutawayTaskViewModel
    @Binding private var path: [OperationType.WorkRoute]
    @State var isScanningEnabled = false
    @State var isEarlyFinishPresented = false

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
            ScannerView(
                isScanningEnabled: $isScanningEnabled,
                idleText: isCellSelected
                    ? "Сканируйте товар" : "Сканируйте ячейку",
                activeText: isCellSelected
                    ? "Сканируем товар..." : "Сканируем ячейку...",
                onScan: { code in processScan(code) }
            )
            itemsList
        }
        .padding([.horizontal, .top], 16)
        .safeAreaInset(edge: .bottom) {
            ZStack {
                if viewModel.isAllItemsPlaced {
                    PrimaryButton(
                        "Закончить задание",
                        background: ColorPalette.success,
                        foreground: ColorPalette.surfacePrimary,
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
        .errorBanner(
            title: "Не удалось разложить товар",
            message: errorMessage
        )
        .task {
            await viewModel.preloadImages()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TaskProgressMenu(
                    doneCount: viewModel.placedItemsCount,
                    totalCount: viewModel.allItemsCount
                ) {
                    if viewModel.placedItemsCount > 0 {
                        Text("Разложено \(viewModel.placedItemsCount)")
                    }
                    Text("Необработано \(viewModel.leftItems.count) шт.")
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
            return "Сначала отсканируйте ячейку"
        case .notAnItem:
            return "Отсканируйте товар"
        case .itemNotInTask:
            return "Этого товара нет в задании"
        case .cellIsFull:
            return "В ячейке нет места"
        case .wrongContainer, nil:
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
            if !viewModel.isAllItemsPlaced {
                Button {
                    viewModel.clearCurrentCell()
                    isEarlyFinishPresented = true
                } label: {
                    Label(
                        "Завершить досрочно",
                        systemImage: "flag.checkered"
                    )
                }
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
                .foregroundStyle(ColorPalette.brandPrimary)
        }
        .confirmationDialog(
            "Досрочное завершение",
            isPresented: $isEarlyFinishPresented,
            titleVisibility: .visible
        ) {
            Button("Завершить", role: .destructive) {
                path.append(.putaway(.finish(viewModel.result)))
            }
        } message: {
            Text(
                "Остались неразложенные товары. В случае досрочного завершения, новые задания раскладки нельзя будет брать до следующей смены. Вы уверены?"
            )
        }

    }

    private var storageCellCard: some View {
        ZStack {
            VStack(spacing: 12) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 40, weight: .light))
                Text("Ячейка не выбрана")
                    .font(.system(size: 20, weight: .medium))
            }
            .foregroundStyle(ColorPalette.brandPrimary)
            .frame(maxWidth: .infinity, minHeight: 140)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        ColorPalette.brandPrimary,
                        style: StrokeStyle(lineWidth: 2, dash: [6])
                    )
            }
            .opacity(isCellSelected ? 0 : 1)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ячейка")
                    Spacer()
                    changeCellButton
                        .padding(.horizontal, -6)
                }
                Text(viewModel.currentCell?.id ?? "Ячейка не выбрана")
                    .font(.system(size: 24, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                ProgressView(value: viewModel.currentCellProgress)
                    .tint(ColorPalette.accentPrimary)
                Text(
                    String(viewModel.currentCellItemsCount) + " из "
                        + String(viewModel.task.cellCapacity)
                )
                .contentTransition(
                    .numericText(value: Double(viewModel.currentCellItemsCount))
                )
            }
            .padding(.horizontal, 16)
            .animation(.snappy, value: viewModel.currentCellItemsCount)
            .foregroundStyle(ColorPalette.brandPrimary)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                    ColorPalette.accentPrimary.opacity(0.18)
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
            Text("Сменить ячейку")
                .padding(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(ColorPalette.brandPrimary, lineWidth: 1)
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
            Text(isCellSelected ? "В ячейке пока пусто" : "Всё разложено")
                .foregroundStyle(ColorPalette.brandMuted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text(
                        isCellSelected
                            ? "Разложенные товары" : "Осталось разложить"
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

            AsyncImage(url: item.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "photo")
                    .font(.system(size: 22))
                    .foregroundStyle(ColorPalette.brandPrimary)
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
