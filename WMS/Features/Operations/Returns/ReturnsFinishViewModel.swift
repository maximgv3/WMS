import Foundation
import Observation

@Observable
final class ReturnsFinishViewModel {
    private let result: ReturnsResult
    private var userId: Int
    private let taskService: ReturnsTaskServiceProtocol
    private let progressStore: ReturnsProgressStoreProtocol

    var isFinishingTask = false
    var errorMessage: String?

    var resultText: String {
        var resultDraft = ""
        for decision in ReturnDecision.allCases where result.count(of: decision) > 0 {
            let decisionTitle = String(localized: decision.title)
            resultDraft += "\(decisionTitle): \(result.count(of: decision))\n"
        }
        if !result.skippedItemIds.isEmpty {
            resultDraft += String(
                localized: .commonSkippedItemsCount(result.skippedItemIds.count)
            )
        }
        return resultDraft
    }

    init(
        result: ReturnsResult,
        userId: Int,
        taskService: ReturnsTaskServiceProtocol,
        progressStore: ReturnsProgressStoreProtocol
    ) {
        self.result = result
        self.userId = userId
        self.taskService = taskService
        self.progressStore = progressStore
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
            progressStore.clear()
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
