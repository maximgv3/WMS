import SwiftUI

struct PickingModuleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoadingTask = false
    private let taskService: PickingTaskServiceProtocol
    @State private var errorMessage: String?
    @State private var userId: Int = 1
    @State private var path: [PickingRoute] = []
    
    init(taskService: PickingTaskServiceProtocol = PickingListServiceMock()) {
        self.taskService = taskService
    }
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                ColorPalette.brandPrimary

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
                    PickingTaskView(pickingTask: task, path: $path)
                case .finish(let collectedItems):
                    PickingFinishView(path: $path, collectedItems: collectedItems, taskService: taskService)
                }
            }
        }
    }

    private var moduleExitDragGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let isMostlyVertical = abs(value.translation.height) > abs(value.translation.width)
                let isSwipeDown = value.translation.height > 120

                if isMostlyVertical && isSwipeDown && path.isEmpty {
                    dismiss()
                }
            }
    }

    private var content: some View {
        VStack(spacing: 60) {
            Button {
                if userId == 1 {
                    userId = 666
                } else {
                    userId = 1
                }
            } label: {
                Image(.pickingList)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
            }
            
            Button {
                Task {
                    await getTaskTapped()
                }
            } label: {
                ZStack {
                    ProgressView()
                        .tint(ColorPalette.brandPrimary)
                        .opacity(isLoadingTask ? 1 : 0)

                    Text("Получить задание")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(ColorPalette.brandPrimary)
                        .opacity(isLoadingTask ? 0 : 1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ColorPalette.accentPrimary)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
            }
            .padding(.horizontal, 64)
            .buttonStyle(.plain)
            .disabled(isLoadingTask)
            .animation(.easeInOut(duration: 0.2), value: isLoadingTask)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary)
        .overlay(alignment: .top) {
            if errorMessage != nil {
                errorBanner
                    .padding(.horizontal, 6)
                    .padding(.vertical, 16)
                    .transition(.move(edge: .top))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: errorMessage)
    }
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
            let result = try await taskService.fetchTask(userId: userId)
            path.append(.task(result))
        } catch {
            errorMessage = error.localizedDescription
            try? await Task.sleep(for: .seconds(3))
            errorMessage = nil
        }
    }

    private var errorBanner: some View {
        VStack(spacing: .zero) {
            Text("Не удалось получить сборочный лист")
                .foregroundStyle(ColorPalette.surfacePrimary)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            if let errorMessage {
                Text(errorMessage)
                    .padding(.top, 4)
                    .foregroundStyle(ColorPalette.surfacePrimary)
                    .font(.system(size: 16, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(ColorPalette.error)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

}

#Preview {
    PickingModuleView()
}
