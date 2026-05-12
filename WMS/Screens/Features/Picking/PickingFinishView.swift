import SwiftUI

struct PickingFinishView: View {
    @Binding private var path: [PickingRoute]
    private let result: PickingResult
    private let taskService: PickingTaskServiceProtocol
    @State private var isFinishingTask = false
    @State private var errorMessage: String?
    private var resultText: String {
        if result.skippedCount > 0 {
            return "Собрано товаров: \(result.collectedCount)\nПропущено: \(result.skippedCount)"
        } else {
            return "Собрано товаров: \(result.collectedCount)"
        }
    }

    init(
        path: Binding<[PickingRoute]>,
        result: PickingResult,
        taskService: PickingTaskServiceProtocol
    ) {
        self._path = path
        self.result = result
        self.taskService = taskService
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

                Text(resultText)
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
            if errorMessage != nil {
                errorBanner
                    .padding(.horizontal, 6)
                    .padding(.vertical, 16)
                    .transition(.move(edge: .top))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: errorMessage)
    }

    private var finishButton: some View {
        Button {
            Task {
                await finish()
            }
        } label: {
            ZStack {
                ProgressView()
                    .tint(ColorPalette.brandPrimary)
                    .opacity(isFinishingTask ? 1 : 0)

                Text("Завершить задание")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(ColorPalette.brandPrimary)
                    .opacity(isFinishingTask ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(ColorPalette.accentPrimary)
            .clipShape(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isFinishingTask)
        .animation(.easeInOut(duration: 0.2), value: isFinishingTask)
    }

    private func finish() async {
        isFinishingTask = true
        defer {
            isFinishingTask = false
        }

        do {
            try await taskService.finishTask(result: result, userId: 1)
            path.removeAll()
        } catch {
            errorMessage = error.localizedDescription
            try? await Task.sleep(for: .seconds(3))
            errorMessage = nil
        }
    }

    private var errorBanner: some View {
        ErrorBannerView(
            title: "Не удалось завершить задание",
            message: errorMessage
        )
    }
}
