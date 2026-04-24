import SwiftUI

struct PickingModuleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoadingTask = false
    private let taskService: PickingTaskServiceProtocol

    init(taskService: PickingTaskServiceProtocol = PickingListServiceMock()) {
        self.taskService = taskService
    }
    var body: some View {
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
    }

    private var content: some View {
        VStack(spacing: 60) {
            Image(.pickingList)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)

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
            try await taskService.fetchTask(userId: 1)
        } catch {
        }
    }
}

#Preview {
    PickingModuleView()
}
