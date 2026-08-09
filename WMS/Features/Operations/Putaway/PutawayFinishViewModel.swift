import Foundation
import Observation

@Observable
final class PutawayFinishViewModel {
    private let result: PutawayResult
    private var userId: Int
    private let taskService: PutawayTaskServiceProtocol

    var isFinishingTask = false
    var errorMessage: String?

    var resultText: String {
        "Разложено товаров: \(result.placedItems.count)"
    }

    init(
        result: PutawayResult,
        userId: Int,
        taskService: PutawayTaskServiceProtocol
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
            FeedbackService.playErrorHaptic()
            errorMessage = error.localizedDescription
            return false
        }
    }

    #if DEBUG
    func toggleTestUserId() {
        userId = userId == 1 ? 666 : 1
    }
    #endif
}
