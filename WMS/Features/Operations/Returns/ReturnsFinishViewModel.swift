import Foundation
import Observation

@Observable
final class ReturnsFinishViewModel {
    private let result: ReturnsResult
    private var userId: Int
    private let taskService: ReturnsTaskServiceProtocol

    var isFinishingTask = false
    var errorMessage: String?

    var resultText: String {
        var resultDraft = ""
        for decision in ReturnDecision.allCases where result.count(of: decision) > 0 {
            resultDraft += decision.title + ": \(result.count(of: decision))\n"
        }
        if !result.skippedItemIds.isEmpty {
            resultDraft += "Пропущено товаров: \(result.skippedItemIds.count)"
        }
        return resultDraft
    }

    init(
        result: ReturnsResult,
        userId: Int,
        taskService: ReturnsTaskServiceProtocol
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
