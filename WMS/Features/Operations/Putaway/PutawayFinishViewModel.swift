import Foundation
import Observation

@Observable
final class PutawayFinishViewModel {
    private let result: PutawayResult
    private var userId: Int
    private let taskService: PutawayTaskServiceProtocol
    private let progressStore: PutawayProgressStoreProtocol

    var isFinishingTask = false
    var errorMessage: String?

    var resultText: String {
        var resultDraft = ""
        if !result.placedItems.isEmpty {
            resultDraft += String(
                localized: .putawayPlacedItemsCount(result.placedItems.count)
            )
        }
        if !result.skippedItemIds.isEmpty {
            resultDraft += String(
                localized: .commonSkippedItemsCount(result.skippedItemIds.count)
            )
        }
        return resultDraft
    }

    init(
        result: PutawayResult,
        userId: Int,
        taskService: PutawayTaskServiceProtocol,
        progressStore: PutawayProgressStoreProtocol
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
