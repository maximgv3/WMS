import Foundation
import Testing

@testable import WMS

@MainActor
struct PickingFinishViewModelTests {

    private let failingUserId = 666

    @Test
    func resultTextShowsCollectedCount() {
        let viewModel = makeViewModel(collectedIds: [1, 2])

        #expect(viewModel.resultText == "Собрано товаров: 2")
    }

    @Test
    func resultTextAddsSkippedLine() {
        let viewModel = makeViewModel(collectedIds: [1, 2], skippedIds: [3])

        #expect(
            viewModel.resultText == """
                Собрано товаров: 2
                Пропущено: 1
                """
        )
    }

    @Test
    func resultTextCountsReplacementsAsCollected() {
        let viewModel = makeViewModel(
            collectedIds: [1],
            replacements: [2: 0, 3: 0]
        )

        #expect(viewModel.resultText == "Собрано товаров: 3")
    }

    @Test
    func resultTextShowsZeroWithoutCollectedItems() {
        let viewModel = makeViewModel()

        #expect(viewModel.resultText == "Собрано товаров: 0")
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
        userId: Int = 1
    ) -> PickingFinishViewModel {
        PickingFinishViewModel(
            result: PickingResult(
                collectedItems: collectedIds.map(makeItem),
                skippedItems: skippedIds.map(makeItem),
                replacements: replacements
            ),
            userId: userId,
            taskService: PickingListServiceMock()
        )
    }
}
