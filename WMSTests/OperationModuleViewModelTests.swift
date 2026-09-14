import Testing

@testable import WMS

@MainActor
struct OperationModuleViewModelTests {
    @Test
    func putawayWithoutSavedProgressStartsWithContainerScan() async {
        let task = makeTask()
        let viewModel = makeViewModel(
            task: task,
            progressStore: PutawayProgressStoreFake()
        )

        let route = await viewModel.fetchTask()

        #expect(route == .putaway(.container(task)))
    }

    @Test
    func putawayWithSavedProgressResumesTaskDirectly() async {
        let task = makeTask()
        let progressStore = PutawayProgressStoreFake(
            progress: PutawayProgress(
                containerId: task.container.id,
                placedItems: [1: "01.02.03.04.05.06"]
            )
        )
        let viewModel = makeViewModel(
            task: task,
            progressStore: progressStore
        )

        let route = await viewModel.fetchTask()

        #expect(route == .putaway(.task(task)))
    }

    @Test
    func putawayWithAnotherContainerDiscardsProgressAndRequestsScan() async {
        let task = makeTask()
        let progressStore = PutawayProgressStoreFake(
            progress: PutawayProgress(
                containerId: "another-container",
                placedItems: [1: "01.02.03.04.05.06"]
            )
        )
        let viewModel = makeViewModel(
            task: task,
            progressStore: progressStore
        )

        let route = await viewModel.fetchTask()

        #expect(route == .putaway(.container(task)))
        #expect(progressStore.progress == nil)
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

    private func makeViewModel(
        task: PutawayTask,
        progressStore: PutawayProgressStoreProtocol
    ) -> OperationModuleViewModel {
        OperationModuleViewModel(
            operationType: .putaway,
            pickingService: PickingListServiceMock(),
            putawayService: PutawayTaskServiceFake(task: task),
            returnsService: ReturnsTaskServiceMock(),
            putawayProgressStore: progressStore
        )
    }
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
