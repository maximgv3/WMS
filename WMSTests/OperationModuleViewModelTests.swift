import Testing

@testable import WMS

@MainActor
struct OperationModuleViewModelTests {
    @Test
    func putawayFetchStartsWithContainerScanAndMarksTaskActive() async {
        let task = makeTask()
        let progressStore = PutawayProgressStoreFake()
        let activeTaskStore = ActiveTaskStoreFake()
        let viewModel = makeViewModel(
            putawayTask: task,
            activeTaskStore: activeTaskStore,
            putawayStore: progressStore
        )

        let route = await viewModel.fetchTask()

        #expect(route == .putaway(.container(task)))
        #expect(progressStore.progress?.containerId == task.container.id)
        #expect(progressStore.progress?.placedItems.isEmpty == true)
        #expect(activeTaskStore.refreshCount == 1)
    }

    @Test
    func putawayFetchKeepsProgressOfTheSameContainer() async {
        let task = makeTask()
        let placedItems = [1: "01.02.03.04.05.06"]
        let progressStore = PutawayProgressStoreFake(
            progress: PutawayProgress(
                containerId: task.container.id,
                placedItems: placedItems
            )
        )
        let viewModel = makeViewModel(
            putawayTask: task,
            putawayStore: progressStore
        )

        let route = await viewModel.fetchTask()

        #expect(route == .putaway(.container(task)))
        #expect(progressStore.progress?.placedItems == placedItems)
    }

    @Test
    func putawayFetchReplacesProgressOfAnotherContainer() async {
        let task = makeTask()
        let progressStore = PutawayProgressStoreFake(
            progress: PutawayProgress(
                containerId: "another-container",
                placedItems: [1: "01.02.03.04.05.06"]
            )
        )
        let viewModel = makeViewModel(
            putawayTask: task,
            putawayStore: progressStore
        )

        let route = await viewModel.fetchTask()

        #expect(route == .putaway(.container(task)))
        #expect(progressStore.progress?.containerId == task.container.id)
        #expect(progressStore.progress?.placedItems.isEmpty == true)
    }

    @Test
    func pickingFetchMarksTaskActive() async {
        let progressStore = PickingProgressStoreFake()
        let activeTaskStore = ActiveTaskStoreFake()
        let viewModel = makeViewModel(
            operationType: .picking,
            activeTaskStore: activeTaskStore,
            pickingStore: progressStore
        )

        let route = await viewModel.fetchTask()

        #expect(route == .picking(.task(makePickingTask())))
        #expect(progressStore.progress?.collectedItemIds.isEmpty == true)
        #expect(activeTaskStore.refreshCount == 1)
    }

    @Test
    func pickingFetchKeepsSavedProgress() async {
        let progressStore = PickingProgressStoreFake(
            progress: PickingProgress(
                collectedItemIds: [1, 2],
                skippedItemIds: [3],
                replacements: [:]
            )
        )
        let viewModel = makeViewModel(
            operationType: .picking,
            pickingStore: progressStore
        )

        _ = await viewModel.fetchTask()

        #expect(progressStore.progress?.collectedItemIds == [1, 2])
        #expect(progressStore.progress?.skippedItemIds == [3])
    }

    @Test
    func returnsFetchMarksTaskActive() async {
        let task = makeReturnsTask()
        let progressStore = ReturnsProgressStoreFake()
        let activeTaskStore = ActiveTaskStoreFake()
        let viewModel = makeViewModel(
            operationType: .returns,
            returnsTask: task,
            activeTaskStore: activeTaskStore,
            returnsStore: progressStore
        )

        let route = await viewModel.fetchTask()

        #expect(route == .returns(.containers(task)))
        #expect(progressStore.progress?.sourceContainerId == task.container.id)
        #expect(progressStore.progress?.decisions.isEmpty == true)
        #expect(activeTaskStore.refreshCount == 1)
    }

    @Test
    func anotherActiveOperationBlocksTaskFetch() async {
        let progressStore = PickingProgressStoreFake()
        let viewModel = makeViewModel(
            operationType: .picking,
            activeTaskStore: ActiveTaskStoreFake(activeOperation: .putaway),
            pickingStore: progressStore
        )

        let route = await viewModel.fetchTask()

        #expect(route == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(progressStore.progress == nil)
    }

    @Test
    func currentOperationIsActiveWhenItOwnsTheSavedTask() {
        let viewModel = makeViewModel(
            operationType: .picking,
            activeTaskStore: ActiveTaskStoreFake(activeOperation: .picking)
        )

        #expect(viewModel.isCurrentOperationActive)
    }

    private func makeTask() -> PutawayTask {
        PutawayTask(
            items: [],
            cellCapacity: 2,
            container: PutawayContainer(
                id: "container-1",
                location: "A1"
            )
        )
    }

    private func makeReturnsTask() -> ReturnsTask {
        ReturnsTask(
            container: ReturnsContainer(id: "returns-container", location: "A2"),
            items: []
        )
    }

    private func makePickingTask() -> PickingTask {
        PickingTask(allItems: [])
    }

    private func makeViewModel(
        operationType: OperationType = .putaway,
        putawayTask: PutawayTask? = nil,
        returnsTask: ReturnsTask? = nil,
        activeTaskStore: ActiveTaskStoreFake? = nil,
        pickingStore: PickingProgressStoreFake? = nil,
        putawayStore: PutawayProgressStoreFake? = nil,
        returnsStore: ReturnsProgressStoreFake? = nil
    ) -> OperationModuleViewModel {
        OperationModuleViewModel(
            operationType: operationType,
            activeTaskStore: activeTaskStore ?? ActiveTaskStoreFake(),
            pickingService: PickingTaskServiceFake(task: makePickingTask()),
            putawayService: PutawayTaskServiceFake(
                task: putawayTask ?? makeTask()
            ),
            returnsService: ReturnsTaskServiceFake(
                task: returnsTask ?? makeReturnsTask()
            ),
            pickingProgressStore: pickingStore ?? PickingProgressStoreFake(),
            putawayProgressStore: putawayStore ?? PutawayProgressStoreFake(),
            returnsProgressStore: returnsStore ?? ReturnsProgressStoreFake()
        )
    }
}

private final class PickingTaskServiceFake: PickingTaskServiceProtocol {
    private let task: PickingTask

    init(task: PickingTask) {
        self.task = task
    }

    func fetchTask(userId: Int) async throws -> PickingTask {
        task
    }

    func checkIfIdAvailableForReplacement(id: Int, replacementId: Int) async
        -> Bool
    {
        false
    }

    func finishTask(result: PickingResult, userId: Int) async throws {}
}

private final class ReturnsTaskServiceFake: ReturnsTaskServiceProtocol {
    private let task: ReturnsTask

    init(task: ReturnsTask) {
        self.task = task
    }

    func fetchTask(userId: Int) async throws -> ReturnsTask {
        task
    }

    func finishTask(result: ReturnsResult, userId: Int) async throws {}
}

private final class PutawayTaskServiceFake: PutawayTaskServiceProtocol {
    private let task: PutawayTask

    init(task: PutawayTask) {
        self.task = task
    }

    func fetchTask(userId: Int) async throws -> PutawayTask {
        task
    }

    func finishTask(result: PutawayResult, userId: Int) async throws {}
}
