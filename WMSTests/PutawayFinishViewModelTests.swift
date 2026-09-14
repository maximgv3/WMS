import Foundation
import Testing

@testable import WMS

@MainActor
struct PutawayFinishViewModelTests {

    private let failingUserId = 666

    @Test
    func resultTextListsPlacedAndSkippedItems() {
        let viewModel = makeViewModel(
            placedItems: [1: "A1", 2: "A2"],
            skippedItemIds: [3]
        )
        let placed = String(localized: .putawayPlacedItemsCount(2))
        let skipped = String(localized: .commonSkippedItemsCount(1))

        #expect(viewModel.resultText == placed + skipped)
    }

    @Test
    func resultTextSkipsPlacedLineWithoutPlacedItems() {
        let viewModel = makeViewModel(skippedItemIds: [1, 2, 3])
        let expected = String(localized: .commonSkippedItemsCount(3))

        #expect(viewModel.resultText == expected)
    }

    @Test
    func resultTextSkipsSkippedLineWithoutSkippedItems() {
        let viewModel = makeViewModel(placedItems: [1: "A1"])
        let expected = String(localized: .putawayPlacedItemsCount(1))

        #expect(viewModel.resultText == expected)
    }

    @Test
    func resultTextIsEmptyWithoutPlacedAndSkippedItems() {
        let viewModel = makeViewModel()

        #expect(viewModel.resultText.isEmpty)
    }

    @Test
    func finishTaskSucceedsWithoutError() async {
        let progressStore = PutawayProgressStoreFake(
            progress: makeProgress()
        )
        let viewModel = makeViewModel(progressStore: progressStore)

        let isFinished = await viewModel.finishTask()

        #expect(isFinished)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isFinishingTask == false)
        #expect(progressStore.progress == nil)
    }

    @Test
    func finishTaskFailsWithErrorMessage() async {
        let progress = makeProgress()
        let progressStore = PutawayProgressStoreFake(progress: progress)
        let viewModel = makeViewModel(
            userId: failingUserId,
            progressStore: progressStore
        )

        let isFinished = await viewModel.finishTask()

        #expect(isFinished == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isFinishingTask == false)
        #expect(progressStore.progress == progress)
    }

    @Test
    func finishTaskIsIgnoredWhileAnotherFinishIsRunning() async {
        let viewModel = makeViewModel()
        viewModel.isFinishingTask = true

        let isFinished = await viewModel.finishTask()

        #expect(isFinished == false)
    }

    @Test
    func secondFinishTaskClearsPreviousError() async {
        let viewModel = makeViewModel(userId: failingUserId)
        _ = await viewModel.finishTask()

        viewModel.toggleTestUserId()
        let isFinished = await viewModel.finishTask()

        #expect(isFinished)
        #expect(viewModel.errorMessage == nil)
    }

    private func makeViewModel(
        placedItems: [Item.ID: StorageCell.ID] = [:],
        skippedItemIds: [Item.ID] = [],
        userId: Int = 1,
        progressStore: PutawayProgressStoreProtocol = PutawayProgressStoreFake()
    ) -> PutawayFinishViewModel {
        PutawayFinishViewModel(
            result: PutawayResult(
                placedItems: placedItems,
                skippedItemIds: skippedItemIds
            ),
            userId: userId,
            taskService: PutawayTaskServiceMock(),
            progressStore: progressStore
        )
    }

    private func makeProgress() -> PutawayProgress {
        PutawayProgress(
            containerId: "container-1",
            placedItems: [1: "01.02.03.04.05.06"]
        )
    }
}
