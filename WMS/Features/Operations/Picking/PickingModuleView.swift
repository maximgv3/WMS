import SwiftUI

struct PickingModuleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PickingModuleViewModel
    @State private var path: [PickingRoute] = []

    init(taskService: PickingTaskServiceProtocol = PickingListServiceMock()) {
        self.viewModel = PickingModuleViewModel(taskService: taskService)
    }
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                ColorPalette.brandPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ModuleHeader(title: "Сборка", onBack: { dismiss() })

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
            .navigationDestination(for: PickingRoute.self) { route in
                switch route {
                case .task(let task):
                    PickingTaskView(pickingTask: task, pickingTaskService: viewModel.taskService, path: $path)
                case .finish(let result):
                    PickingFinishView(
                        path: $path,
                        result: result,
                        userId: viewModel.userId,
                        taskService: viewModel.taskService
                    )
                }
            }
        }
    }

    private var moduleExitDragGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let isMostlyVertical = abs(value.translation.height) > abs(value.translation.width)
                let isSwipeDown = value.translation.height > 120
                let isMostlyHorizontal = abs(value.translation.width) > abs(value.translation.height)
                let isSwipeRight = value.translation.width > 90
                let isStartedFromLeadingEdge = value.startLocation.x < 32

                if path.isEmpty && isMostlyVertical && isSwipeDown {
                    dismiss()
                }

                if path.isEmpty && isMostlyHorizontal && isSwipeRight && isStartedFromLeadingEdge {
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
                pickingListImage
            }
            .buttonStyle(.plain)
            #else
            pickingListImage
            #endif
            PrimaryButton("Получить задание", isLoading: viewModel.isLoadingTask) {
                Task {
                    await getTaskTapped()
                }
            }
            .padding(.horizontal, 64)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary)
        .errorBanner(title: "Не удалось получить сборочный лист", message: $viewModel.errorMessage)
    }

    private var pickingListImage: some View {
        Image(.pickingList)
            .resizable()
            .scaledToFit()
            .frame(width: 140, height: 140)
    }

    private func getTaskTapped() async {
        if let task = await viewModel.fetchTask() {
            path.append(.task(task))
        }
    }

}

#Preview {
    PickingModuleView()
}
