import SwiftUI

struct PickingModuleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoadingTask = false
    private let pickingTaskService: PickingTaskServiceProtocol
    @State private var errorMessage: String?
    @State private var userId: Int = 1
    @State private var path: [PickingRoute] = []
    
    init(taskService: PickingTaskServiceProtocol = PickingListServiceMock()) {
        self.pickingTaskService = taskService
    }
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                ColorPalette.brandPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    customTopBar
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
                    PickingTaskView(pickingTask: task, pickingTaskService: pickingTaskService, path: $path)
                case .finish(let result):
                    PickingFinishView(
                        path: $path,
                        result: result,
                        userId: userId,
                        taskService: pickingTaskService
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
                toggleTestUserId()
            } label: {
                pickingListImage
            }
            .buttonStyle(.plain)
            #else
            pickingListImage
            #endif
            PrimaryButton("Получить задание", isLoading: isLoadingTask) {
                Task {
                    await getTaskTapped()
                }
            }
            .padding(.horizontal, 64)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary)
        .errorBanner(title: "Не удалось получить сборочный лист", message: $errorMessage)
    }

    private var pickingListImage: some View {
        Image(.pickingList)
            .resizable()
            .scaledToFit()
            .frame(width: 140, height: 140)
    }

    #if DEBUG
    private func toggleTestUserId() {
        if userId == 1 {
            userId = 666
        } else {
            userId = 1
        }
    }
    #endif

    private var customTopBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .offset(y: 1.5)
            }
            .buttonStyle(.plain)

            Text("Сборка")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(ColorPalette.brandPrimary)
    }

    private func getTaskTapped() async {
        isLoadingTask = true
        defer {
            isLoadingTask = false
        }
        do {
            let result = try await pickingTaskService.fetchTask(userId: userId)
            path.append(.task(result))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}

#Preview {
    PickingModuleView()
}
