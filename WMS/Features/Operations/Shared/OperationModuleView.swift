import SwiftUI

struct OperationModuleView: View {
    @Environment(\.dismiss) private var dismiss
    let operationType: OperationType
    @State private var viewModel: OperationModuleViewModel
    @State private var path: [OperationType.WorkRoute] = []

    init(
        operationType: OperationType,
        pickingService: PickingTaskServiceProtocol = PickingListServiceMock(),
        putawayService: PutawayTaskServiceProtocol = PutawayTaskServiceMock(),
        returnsService: ReturnsTaskServiceProtocol = ReturnsTaskServiceMock()
    ) {
        self.operationType = operationType
        self.viewModel = OperationModuleViewModel(
            operationType: operationType,
            pickingService: pickingService,
            putawayService: putawayService,
            returnsService: returnsService
        )
    }
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                ColorPalette.brandPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ModuleHeader(
                        title: operationType.title,
                        onBack: { dismiss() }
                    )

                    content
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 28,
                                topTrailingRadius: 28
                            )
                        )
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationBarBackButtonHidden()
            .gesture(moduleExitDragGesture)
            .navigationDestination(for: OperationType.WorkRoute.self) { route in
                switch route {
                case .picking(let pickingRoute):
                    switch pickingRoute {
                    case .task(let task):
                        PickingTaskView(
                            pickingTask: task,
                            pickingTaskService: viewModel.pickingService,
                            path: $path
                        )
                    case .finish(let result):
                        PickingFinishView(
                            path: $path,
                            result: result,
                            userId: viewModel.userId,
                            taskService: viewModel.pickingService
                        )
                    }
                case .putaway(let putawayRoute):
                    switch putawayRoute {
                    case .container(let task):
                        PutawayContainerView(task: task, path: $path)
                    case .task(let task):
                        PutawayTaskView(task: task, service: viewModel.putawayService, path: $path)
                    case .finish(let result):
                        PutawayFinishView(
                            path: $path,
                            result: result,
                            userId: viewModel.userId,
                            taskService: viewModel.putawayService
                        )
                    }
                case .returns(let returnsRoute):
                    switch returnsRoute {
                    case .task(let task):
                        ReturnsTaskView(
                            task: task,
                            service: viewModel.returnsService,
                            path: $path
                        )
                    case .finish(let result):
                        ReturnsFinishView(
                            path: $path,
                            result: result,
                            userId: viewModel.userId,
                            taskService: viewModel.returnsService
                        )
                    }
                }
            }
        }
    }

    private var moduleExitDragGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let isMostlyVertical =
                    abs(value.translation.height) > abs(value.translation.width)
                let isSwipeDown = value.translation.height > 120
                let isMostlyHorizontal =
                    abs(value.translation.width) > abs(value.translation.height)
                let isSwipeRight = value.translation.width > 90
                let isStartedFromLeadingEdge = value.startLocation.x < 32

                if path.isEmpty && isMostlyVertical && isSwipeDown {
                    dismiss()
                }

                if path.isEmpty && isMostlyHorizontal && isSwipeRight
                    && isStartedFromLeadingEdge
                {
                    dismiss()
                }
            }
    }

    private var content: some View {
        VStack(spacing: 60) {
            #if DEBUG
                Button {
                    viewModel.toggleTestUserId()
                } label: {
                    operationImage
                }
                .buttonStyle(.plain)
            #else
                operationImage
            #endif
            PrimaryButton(
                "Получить задание",
                isLoading: viewModel.isLoadingTask
            ) {
                Task {
                    await getTaskTapped()
                }
            }
            .padding(.horizontal, 64)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary)
        .errorBanner(
            title: operationType.fetchErrorTitle,
            message: $viewModel.errorMessage
        )
    }

    private var operationImage: some View {
        Group {
            switch operationType {
            case .putaway:
                Image(.putaway)
                    .resizable()
                    .scaledToFit()
            case .picking:
                Image(.picking)
                    .resizable()
                    .scaledToFit()
            case .returns:
                Image(.returns)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: 250, height: 250)

    }

    private func getTaskTapped() async {
        if let route = await viewModel.fetchTask() {
            path.append(route)
        }
    }

}

#Preview("Сборка") {
    OperationModuleView(operationType: .picking)
}
#Preview("Раскладка") {
    OperationModuleView(operationType: .putaway)
}
#Preview("Проверка возвратов") {
    OperationModuleView(operationType: .returns)
}

