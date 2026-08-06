import Foundation
import Observation

@Observable
final class PickingModuleViewModel {
    var isLoadingTask = false
    var errorMessage: String?
    private(set) var userId = 1

    let taskService: PickingTaskServiceProtocol

    init(taskService: PickingTaskServiceProtocol = PickingListServiceMock()) {
        self.taskService = taskService
    }

    func fetchTask() async -> PickingTask? {
        isLoadingTask = true
        defer {
            isLoadingTask = false
        }
        do {
            return try await taskService.fetchTask(userId: userId)
        } catch {
            FeedbackService.playErrorHaptic()
            errorMessage = error.localizedDescription
            return nil
        }
    }

    #if DEBUG
    func toggleTestUserId() {
        userId = userId == 1 ? 666 : 1
    }
    #endif
}
