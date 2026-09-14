import Foundation
import Testing

@testable import WMS

@MainActor
struct PickingFinishViewModelTests {

    private let failingUserId = 666

    @Test
    func resultTextShowsCollectedCount() {
        let viewModel = makeViewModel(collectedIds: [1, 2])
        let expected = String(localized: .pickingPickedItemsCount(2))

        #expect(viewModel.resultText == expected)
    }

    @Test
    func resultTextAddsSkippedLine() {
        let viewModel = makeViewModel(collectedIds: [1, 2], skippedIds: [3])
        let expected = String(localized: .pickingResultSummary(2, 1))

        #expect(viewModel.resultText == expected)
    }

    @Test
    func resultTextCountsReplacementsAsCollected() {
        let viewModel = makeViewModel(
            collectedIds: [1],
            replacements: [2: 0, 3: 0]
        )
        let expected = String(localized: .pickingPickedItemsCount(3))

        #expect(viewModel.resultText == expected)
    }

    @Test
    func resultTextShowsZeroWithoutCollectedItems() {
        let viewModel = makeViewModel()
        let expected = String(localized: .pickingPickedItemsCount(0))

        #expect(viewModel.resultText == expected)
    }

    @Test
    func finishTaskSucceedsWithoutError() async {
        let progress = PickingProgress(
            collectedItemIds: [1],
            skippedItemIds: [],
            replacements: [:]
        )
        let progressStore = PickingProgressStoreFake(progress: progress)
        let viewModel = makeViewModel(progressStore: progressStore)

        let isFinished = await viewModel.finishTask()

        #expect(isFinished)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isFinishingTask == false)
        #expect(progressStore.progress == nil)
    }

    @Test
    func finishTaskFailsWithErrorMessage() async {
        let progress = PickingProgress(
            collectedItemIds: [1],
            skippedItemIds: [],
            replacements: [:]
        )
        let progressStore = PickingProgressStoreFake(progress: progress)
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

    private func makeItem(id: Int) -> Item {
        Item(
            id: id,
            barcode: "",
            article: "",
            brand: "",
            title: "",
            size: "",
            color: "",
            imageUrl: nil,
            placement: nil,
            price: 0,
            stock: 0
        )
    }

    private func makeViewModel(
        collectedIds: [Int] = [],
        skippedIds: [Int] = [],
        replacements: [Item.ID: Int] = [:],
        userId: Int = 1,
        progressStore: PickingProgressStoreProtocol = PickingProgressStoreFake()
    ) -> PickingFinishViewModel {
        PickingFinishViewModel(
            result: PickingResult(
                collectedItems: collectedIds.map(makeItem),
                skippedItems: skippedIds.map(makeItem),
                replacements: replacements
            ),
            userId: userId,
            taskService: PickingListServiceMock(),
            progressStore: progressStore
        )
    }
}
