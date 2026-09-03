import Foundation
import Testing

@testable import WMS

@MainActor
struct ReturnsFinishViewModelTests {

    private let failingUserId = 666

    @Test
    func resultTextListsDecisionsWithCountsAndSkippedItems() {
        let viewModel = makeViewModel(
            decisions: [1: .good, 2: .defect, 3: .defect, 4: .wrongItem],
            skippedItemIds: [5, 6]
        )

        #expect(
            viewModel.resultText == """
                Годен: 1
                Брак: 2
                Подмена: 1
                Пропущено товаров: 2
                """
        )
    }

    @Test
    func resultTextSkipsDecisionsWithoutItems() {
        let viewModel = makeViewModel(decisions: [1: .good])

        #expect(viewModel.resultText == "Годен: 1\n")
    }

    @Test
    func resultTextCountsSkippedItemsWithoutDecisions() {
        let viewModel = makeViewModel(skippedItemIds: [1, 2, 3])

        #expect(viewModel.resultText == "Пропущено товаров: 3")
    }

    @Test
    func resultTextIsEmptyWithoutDecisionsAndSkippedItems() {
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
        decisions: [Item.ID: ReturnDecision] = [:],
        skippedItemIds: [Item.ID] = [],
        userId: Int = 1
    ) -> ReturnsFinishViewModel {
        ReturnsFinishViewModel(
            result: ReturnsResult(
                decisions: decisions,
                photos: [:],
                containers: [:],
                sourceContainerId: "",
                skippedItemIds: skippedItemIds
            ),
            userId: userId,
            taskService: ReturnsTaskServiceMock()
        )
    }
}
