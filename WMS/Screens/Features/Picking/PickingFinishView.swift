import SwiftUI

struct PickingFinishView: View {
    @Binding private var path: [PickingRoute]
    @State private var viewModel: PickingFinishViewModel

    init(
        path: Binding<[PickingRoute]>,
        result: PickingResult,
        userId: Int,
        taskService: PickingTaskServiceProtocol
    ) {
        self._path = path
        self.viewModel = .init(
            result: result,
            userId: userId,
            taskService: taskService
        )
    }

    var body: some View {
        content
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden(true)
    }

    private var content: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72, weight: .semibold))
                    .foregroundStyle(ColorPalette.accentPrimary)

                Text("Сборка завершена")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(ColorPalette.brandPrimary)

                Text(viewModel.resultText)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(ColorPalette.brandMuted)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            Spacer()

            finishButton
                .padding(.horizontal, 64)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary)
        .overlay(alignment: .top) {
            if viewModel.errorMessage != nil {
                errorBanner
                    .padding(.horizontal, 6)
                    .padding(.vertical, 16)
                    .transition(.move(edge: .top))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.errorMessage)
    }

    private var finishButton: some View {
        PrimaryButton("Завершить задание", isLoading: viewModel.isFinishingTask) {
            Task {
                await finish()
            }
        }
    }

    private func finish() async {
        let isFinished = await viewModel.finishTask()
        if isFinished {
            path.removeAll()
        }
    }

    private var errorBanner: some View {
        ErrorBannerView(
            title: "Не удалось завершить задание",
            message: viewModel.errorMessage
        )
    }
}
