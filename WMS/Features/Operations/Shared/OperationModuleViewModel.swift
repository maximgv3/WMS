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
    let returnsService: ReturnsTaskServiceProtocol

    init(operationType: OperationType, pickingService: PickingTaskServiceProtocol, putawayService: PutawayTaskServiceProtocol, returnsService: ReturnsTaskServiceProtocol) {
        self.operationType = operationType
        self.pickingService = pickingService
        self.putawayService = putawayService
        self.returnsService = returnsService
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
                return .putaway(.container(task))
            case .picking:
                let task = try await pickingService.fetchTask(userId: userId)
                return .picking(.task(task))
            case .returns:
                let task = try await returnsService.fetchTask(userId: userId)
                return .returns(.task(task))
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
