import SwiftUI
import UIKit

struct ReturnsTaskView: View {

    @State private var viewModel: ReturnsTaskViewModel
    @Binding private var path: [OperationType.WorkRoute]
    @State private var isScanningEnabled = false
    @State private var isEarlyFinishPresented = false
    @State private var pendingDecision: ReturnDecision?

    #if DEBUG
        @AppStorage("isReturnsDemoModeOn") private var isDemoModeOn = false
        @State private var isDemoConfirmationPresented = false

        private let demoWrongCode = "0000000000"
        private let demoContainerCode = "WMSCT770999"
    #endif

    init(
        task: ReturnsTask,
        containers: ReturnsContainers,
        service: ReturnsTaskServiceProtocol,
        path: Binding<[OperationType.WorkRoute]>
    ) {
        self.viewModel = ReturnsTaskViewModel(
            task: task,
            containers: containers,
            service: service
        )
        self._path = path
    }

    var body: some View {
        VStack(spacing: 16) {
            returnCard
            scanner
            containersRow
            content
        }
        .padding([.horizontal, .top], 16)
        .safeAreaInset(edge: .bottom) {
            ZStack {
                if isFinishAvailable {
                    PrimaryButton(
                        "Закончить задание",
                        background: ColorPalette.success,
                        foreground: ColorPalette.surfacePrimary,
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
        .errorBanner(
            title: errorTitle,
            message: errorMessage
        )
        .fullScreenCover(item: $pendingDecision) { decision in
            CameraPickerView { image in
                pendingDecision = nil
                guard let data = image?.jpegData(compressionQuality: 0.6) else {
                    return
                }
                applyDecision(decision, photo: data)
            }
            .ignoresSafeArea()
        }
        .task {
            await viewModel.preloadImages()
        }
        .onAppear {
            disableDemoMode()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TaskProgressMenu(
                    doneCount: viewModel.checkedItemsCount,
                    totalCount: viewModel.allItemsCount
                ) {
                    if viewModel.checkedItemsCount > 0 {
                        Text("Проверено \(viewModel.checkedItemsCount)")
                    }
                    Text("Осталось \(viewModel.leftItems.count) шт.")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                exitMenu
            }
        }
    }

    private var isFinishAvailable: Bool {
        viewModel.isAllItemsChecked && viewModel.currentItem == nil
    }

    private var errorText: String? {
        switch viewModel.lastError {
        case .notAnItem:
            return "Отсканируйте товар"
        case .itemNotInTask:
            return "Товара нет в задании"
        case .decisionRequired:
            return "Сначала выберите решение по товару"
        case .notAContainer:
            return "Отсканируйте тару"
        case .containerAlreadyUsed:
            return "Эта тара уже занята"
        case .wrongContainer, nil:
            return nil
        }
    }

    private var errorTitle: String {
        switch viewModel.lastError {
        case .notAContainer, .containerAlreadyUsed:
            "Не удалось сменить тару"
        default:
            "Не удалось проверить товар"
        }
    }

    private var containersRow: some View {
        HStack(spacing: 8) {
            ForEach(ReturnContainerSlot.allCases) { slot in
                containerChip(slot)
            }
        }
    }

    private func containerChip(_ slot: ReturnContainerSlot) -> some View {
        Button {
            withAnimation(.snappy) {
                viewModel.startRebinding(slot)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: slot.iconName)
                    .foregroundStyle(color(for: slot))
                VStack(alignment: .leading, spacing: 0) {
                    Text(slot.title)
                        .font(.system(size: 13))
                        .foregroundStyle(ColorPalette.brandMuted)
                    Text(viewModel.containers[slot])
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .monospacedDigit()
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(
                    color(for: slot).opacity(isRebinding(slot) ? 0.28 : 0.12)
                )
            )
            .overlay {
                if isRebinding(slot) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(color(for: slot), lineWidth: 2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(DecisionButtonStyle())
        .foregroundStyle(ColorPalette.brandPrimary)
    }

    private var errorMessage: Binding<String?> {
        Binding(
            get: { errorText },
            set: { if $0 == nil { viewModel.clearError() } }
        )
    }

    private var exitMenu: some View {
        Menu {
            if !viewModel.isAllItemsChecked {
                Button {
                    withAnimation(.snappy) {
                        viewModel.clearCurrentItem()
                    }
                    isEarlyFinishPresented = true
                } label: {
                    Label(
                        "Завершить досрочно",
                        systemImage: "flag.checkered"
                    )
                }
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
                path.append(.returns(.finish(viewModel.result)))
            }
        } message: {
            Text(
                "Остались непроверенные товары. В случае досрочного завершения, новые задания проверки нельзя будет брать до следующей смены. Вы уверены?"
            )
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
                    "Демо-режим заменит камеру на кнопки: ошибочный скан и скан следующего товара из задания. Это удобно для прохождения флоу без реальной камеры. Доступен только в debug-сборке."
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
            idleText: isRebindingAnySlot
                ? "Сканируйте тару" : "Сканируйте товар",
            activeText: isRebindingAnySlot
                ? "Сканируем тару..." : "Сканируем товар...",
            onScan: { code in processScan(code) }
        )
    }

    private var isRebindingAnySlot: Bool { viewModel.rebindingSlot != nil }

    private func isRebinding(_ slot: ReturnContainerSlot) -> Bool {
        viewModel.rebindingSlot == slot
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

                if isRebindingAnySlot {
                    Button {
                        processScan(demoContainerCode)
                    } label: {
                        Text("Тара")
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
                } else if let returnItem = viewModel.leftItems.first
                    ?? viewModel.task.items.first
                {
                    Button {
                        processScan(String(returnItem.id))
                    } label: {
                        Text("Товар")
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

        private func demoButtonTapped() {
            if isDemoModeOn {
                demoModeToggle()
            } else {
                isDemoConfirmationPresented = true
            }
        }

        private var demoPhoto: Data {
            UIImage(systemName: "photo")?.pngData() ?? Data()
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

    private var returnCard: some View {
        ZStack {
            if let returnItem = viewModel.currentItem {
                itemCard(returnItem)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                emptyCard
                    .transition(.opacity)
            }
        }
    }

    private var emptyCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 40, weight: .light))
            Text("Товар не отсканирован")
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
    }

    private func itemCard(_ returnItem: ReturnItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                itemImage(returnItem.item)
                    .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title(for: returnItem.item))
                        .font(.system(size: 20, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text.itemId(returnItem.id)
                        .monospacedDigit()
                }
                Spacer()
            }

            HStack(spacing: 6) {
                Image(systemName: "arrow.uturn.backward")
                Text("Причина: " + returnItem.reason)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .padding(16)
        .foregroundStyle(ColorPalette.brandPrimary)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                ColorPalette.accentPrimary.opacity(0.18)
            )
        )
    }

    private var isDecisionPending: Bool { viewModel.currentItem != nil }

    private var content: some View {
        ZStack(alignment: .top) {
            itemsList
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
            Text("Осмотрите товар и выберите решение")
                .font(.headline)
            ForEach(ReturnDecision.allCases) { decision in
                decisionButton(decision)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func decisionButton(_ decision: ReturnDecision) -> some View {
        Button {
            decisionTapped(decision)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: decision.iconName)
                    .font(.system(size: 26))
                    .foregroundStyle(color(for: decision))
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(decision.title)
                        .font(.system(size: 18, weight: .semibold))
                    Text(decision.subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(ColorPalette.brandMuted)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                    color(for: decision).opacity(0.12)
                )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(DecisionButtonStyle())
        .foregroundStyle(ColorPalette.brandPrimary)
    }

    private var listedItems: [ReturnItem] {
        viewModel.leftItems + viewModel.checkedItems
    }

    private var itemsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if !viewModel.leftItems.isEmpty {
                    Text("Осталось проверить")
                        .font(.headline)
                }

                // One ForEach for both groups keeps a row alive when it moves down
                ForEach(listedItems) { returnItem in
                    if returnItem.id == viewModel.checkedItems.first?.id {
                        Text("Проверено")
                            .font(.headline)
                            .padding(.top, 12)
                    }
                    itemRow(returnItem)
                }
            }
            .animation(.snappy, value: listedItems)
        }
        .scrollIndicators(.hidden)
    }

    private func itemRow(_ returnItem: ReturnItem) -> some View {
        HStack(spacing: 12) {
            itemImage(returnItem.item)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(title(for: returnItem.item))
                    .lineLimit(1)
                Text(returnItem.reason)
                    .font(.system(size: 14))
                    .foregroundStyle(ColorPalette.brandMuted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text.itemId(returnItem.id)
                .lineLimit(1)
                .layoutPriority(1)
                .monospacedDigit()

            if let decision = viewModel.decisions[returnItem.id] {
                Image(systemName: decision.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(color(for: decision))
                    .frame(width: 20)
            }
        }
    }

    private func itemImage(_ item: Item) -> some View {
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
    }

    private var itemImagePlaceholder: some View {
        Image(systemName: "photo")
            .font(.system(size: 22))
            .foregroundStyle(ColorPalette.brandPrimary)
    }

    private func color(for slot: ReturnContainerSlot) -> Color {
        switch slot {
        case .good:
            ColorPalette.success
        case .inspection:
            ColorPalette.error
        }
    }

    private func color(for decision: ReturnDecision) -> Color {
        switch decision {
        case .good:
            ColorPalette.success
        case .defect:
            ColorPalette.error
        case .wrongItem:
            ColorPalette.brandMuted
        }
    }

    private func decisionTapped(_ decision: ReturnDecision) {
        #if DEBUG
            if isDemoModeOn && decision.requiresPhoto {
                applyDecision(decision, photo: demoPhoto)
                return
            }
        #endif

        if decision.requiresPhoto {
            pendingDecision = decision
        } else {
            applyDecision(decision, photo: nil)
        }
    }

    private func applyDecision(_ decision: ReturnDecision, photo: Data?) {
        withAnimation(.snappy) {
            viewModel.decide(decision, photo: photo)
        }
        FeedbackService.playSuccess()
    }

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

    private func title(for item: Item) -> String {
        guard let detail = item.size ?? item.color ?? item.brand else {
            return item.title
        }
        return item.title + ", " + detail
    }
}

private struct DecisionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
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
