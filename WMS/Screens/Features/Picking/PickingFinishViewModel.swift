import Foundation
import Observation

@Observable
final class PickingFinishViewModel {
    private let result: PickingResult
    private let userId: Int
    private let taskService: PickingTaskServiceProtocol

    var isFinishingTask = false
    var errorMessage: String?

    var resultText: String {
        if result.skippedCount > 0 {
            return "Собрано товаров: \(result.collectedCount)\nПропущено: \(result.skippedCount)"
        } else {
            return "Собрано товаров: \(result.collectedCount)"
        }
    }

    init(
        result: PickingResult,
        userId: Int,
        taskService: PickingTaskServiceProtocol
    ) {
        self.result = result
        self.userId = userId
        self.taskService = taskService
    }

    func finishTask() async -> Bool {
        guard !isFinishingTask else { return false }

        isFinishingTask = true
        errorMessage = nil

        defer {
            isFinishingTask = false
        }

        do {
            try await taskService.finishTask(result: result, userId: userId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
