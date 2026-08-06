import Foundation
import Observation

@Observable
final class OperationModuleViewModel {
    var isLoadingTask = false
    var errorMessage: String?
    private(set) var userId = 1

    let operationType: OperationType
    let pickingService: PickingTaskServiceProtocol
    let putawayService: PutawayTaskServiceProtocol

    init(operationType: OperationType, pickingService: PickingTaskServiceProtocol, putawayService: PutawayTaskServiceProtocol) {
        self.operationType = operationType
        self.pickingService = pickingService
        self.putawayService = putawayService
    }

    func fetchTask() async -> OperationType.WorkRoute? {
        isLoadingTask = true
        defer {
            isLoadingTask = false
        }

        do {
            switch operationType {
            case .putaway:
                let task = try await putawayService.fetchTask(userId: userId)
                return .putaway(.task(task))
            case .picking:
                let task = try await pickingService.fetchTask(userId: userId)
                return .picking(.task(task))
            case .returns:
                return nil
            }
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
