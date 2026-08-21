import SwiftUI

struct PutawayContainerView: View {

    @State private var viewModel: PutawayContainerViewModel
    @Binding private var path: [OperationType.WorkRoute]
    @State private var isScanningEnabled = false

    private let task: PutawayTask

    init(
        task: PutawayTask,
        path: Binding<[OperationType.WorkRoute]>
    ) {
        self.task = task
        self.viewModel = PutawayContainerViewModel(container: task.container)
        self._path = path
    }

    var body: some View {
        VStack(spacing: 16) {
            containerCard
            ScannerView(
                isScanningEnabled: $isScanningEnabled,
                idleText: "Сканируйте контейнер",
                activeText: "Сканируем контейнер...",
                previewHeight: 400,
                onScan: { code in processScan(code) }
            )
            Text("Найдите контейнер на месте\nи отсканируйте его код")
                .multilineTextAlignment(.center)
                .foregroundStyle(ColorPalette.brandMuted)
                .frame(maxWidth: .infinity, minHeight: 56, maxHeight: .infinity)
        }
        .padding([.horizontal, .top], 16)
        .errorBanner(
            title: "Не удалось начать раскладку",
            message: errorMessage
        )
    }

    private var errorText: String? {
        switch viewModel.lastError {
        case .wrongContainer:
            return "Это не тот контейнер"
        case .notACell, .notAnItem, .itemNotInTask, .cellIsFull, nil:
            return nil
        }
    }

    private var errorMessage: Binding<String?> {
        Binding(
            get: { errorText },
            set: { if $0 == nil { viewModel.clearError() } }
        )
    }

    private var containerCard: some View {

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 24) {
                Image(systemName: "tray.full")
                    .font(.system(size: 40))
                VStack(alignment: .leading, spacing: 12) {
                    Text("Контейнер")
                    Text(viewModel.container.id)
                        .font(.system(size: 24, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(viewModel.container.location)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .foregroundStyle(ColorPalette.brandPrimary)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                ColorPalette.accentPrimary.opacity(0.18)
            )
        )
    }

    private func processScan(_ code: String) {
        viewModel.processCode(code)

        if viewModel.lastError == nil {
            FeedbackService.playSuccess()
            path.append(.putaway(.task(task)))
        } else {
            FeedbackService.playError()
        }
    }
}

#Preview {
    @Previewable @State var path: [OperationType.WorkRoute] = []

    NavigationStack(path: $path) {
        PutawayContainerView(
            task: MockData.putawayTaskMock,
            path: $path
        )
    }
}
