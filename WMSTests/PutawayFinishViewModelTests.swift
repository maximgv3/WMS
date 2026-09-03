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

        #expect(
            viewModel.resultText == """
                Разложено товаров: 2
                Пропущено товаров: 1
                """
        )
    }

    @Test
    func resultTextSkipsPlacedLineWithoutPlacedItems() {
        let viewModel = makeViewModel(skippedItemIds: [1, 2, 3])

        #expect(viewModel.resultText == "Пропущено товаров: 3")
    }

    @Test
    func resultTextSkipsSkippedLineWithoutSkippedItems() {
        let viewModel = makeViewModel(placedItems: [1: "A1"])

        #expect(viewModel.resultText == "Разложено товаров: 1\n")
    }

    @Test
    func resultTextIsEmptyWithoutPlacedAndSkippedItems() {
        let viewModel = makeViewModel()

        #expect(viewModel.resultText.isEmpty)
    }

    @Test
    func finishTaskSucceedsWithoutError() async {
        let viewModel = makeViewModel()

        let isFinished = await viewModel.finishTask()

        #expect(isFinished)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isFinishingTask == false)
    }

    @Test
    func finishTaskFailsWithErrorMessage() async {
        let viewModel = makeViewModel(userId: failingUserId)

        let isFinished = await viewModel.finishTask()

        #expect(isFinished == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isFinishingTask == false)
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
        userId: Int = 1
    ) -> PutawayFinishViewModel {
        PutawayFinishViewModel(
            result: PutawayResult(
                placedItems: placedItems,
                skippedItemIds: skippedItemIds
            ),
            userId: userId,
            taskService: PutawayTaskServiceMock()
        )
    }
}
