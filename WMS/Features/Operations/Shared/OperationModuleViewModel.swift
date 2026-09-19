import Foundation
import Observation

@Observable
final class OperationModuleViewModel {
    var isLoadingTask = false
    var errorMessage: String?
    private(set) var userId = 1

    let operationType: OperationType
    let activeTaskStore: ActiveTaskStoreProtocol
    let pickingService: PickingTaskServiceProtocol
    let putawayService: PutawayTaskServiceProtocol
    let returnsService: ReturnsTaskServiceProtocol
    let pickingProgressStore: PickingProgressStoreProtocol
    let putawayProgressStore: PutawayProgressStoreProtocol
    let returnsProgressStore: ReturnsProgressStoreProtocol

    var isCurrentOperationActive: Bool {
        activeTaskStore.activeOperation == operationType
    }

    init(
        operationType: OperationType,
        activeTaskStore: ActiveTaskStoreProtocol,
        pickingService: PickingTaskServiceProtocol,
        putawayService: PutawayTaskServiceProtocol,
        returnsService: ReturnsTaskServiceProtocol,
        pickingProgressStore: PickingProgressStoreProtocol,
        putawayProgressStore: PutawayProgressStoreProtocol,
        returnsProgressStore: ReturnsProgressStoreProtocol
    ) {
        self.operationType = operationType
        self.activeTaskStore = activeTaskStore
        self.pickingService = pickingService
        self.putawayService = putawayService
        self.returnsService = returnsService
        self.pickingProgressStore = pickingProgressStore
        self.putawayProgressStore = putawayProgressStore
        self.returnsProgressStore = returnsProgressStore
    }

    func fetchTask() async -> OperationType.WorkRoute? {
        guard activeTaskStore.activeOperation == nil || isCurrentOperationActive
        else {
            errorMessage = String(localized: .operationsFinishActiveTaskFirst)
            return nil
        }

        isLoadingTask = true
        defer {
            isLoadingTask = false
        }

        do {
            let route: OperationType.WorkRoute

            switch operationType {
            case .putaway:
                let task = try await putawayService.fetchTask(userId: userId)
                if putawayProgressStore.load(for: task.container.id) == nil {
                    putawayProgressStore.save(
                        PutawayProgress(
                            containerId: task.container.id,
                            placedItems: [:]
                        )
                    )
                }
                route = .putaway(.container(task))
            case .picking:
                let task = try await pickingService.fetchTask(userId: userId)
                if pickingProgressStore.load() == nil {
                    pickingProgressStore.save(
                        PickingProgress(
                            collectedItemIds: [],
                            skippedItemIds: [],
                            replacements: [:]
                        )
                    )
                }
                route = .picking(.task(task))
            case .returns:
                let task = try await returnsService.fetchTask(userId: userId)
                if returnsProgressStore.load(for: task.container.id) == nil {
                    returnsProgressStore.save(
                        ReturnsProgress(
                            sourceContainerId: task.container.id,
                            decisions: [:],
                            photos: [:],
                            itemContainers: [:]
                        )
                    )
                }
                route = .returns(.containers(task))
            }

            activeTaskStore.refresh()
            return route
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
