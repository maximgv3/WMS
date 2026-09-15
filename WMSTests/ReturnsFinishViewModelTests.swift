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
        let good = String(localized: ReturnDecision.good.title)
        let defect = String(localized: ReturnDecision.defect.title)
        let wrongItem = String(localized: ReturnDecision.wrongItem.title)
        let skipped = String(localized: .commonSkippedItemsCount(2))

        #expect(
            viewModel.resultText == """
                \(good): 1
                \(defect): 2
                \(wrongItem): 1
                \(skipped)
                """
        )
    }

    @Test
    func resultTextSkipsDecisionsWithoutItems() {
        let viewModel = makeViewModel(decisions: [1: .good])
        let good = String(localized: ReturnDecision.good.title)

        #expect(viewModel.resultText == "\(good): 1\n")
    }

    @Test
    func resultTextCountsSkippedItemsWithoutDecisions() {
        let viewModel = makeViewModel(skippedItemIds: [1, 2, 3])
        let expected = String(localized: .commonSkippedItemsCount(3))

        #expect(viewModel.resultText == expected)
    }

    @Test
    func resultTextIsEmptyWithoutDecisionsAndSkippedItems() {
        let viewModel = makeViewModel()

        #expect(viewModel.resultText.isEmpty)
    }

    @Test
    func finishTaskSucceedsWithoutError() async {
        let progressStore = makeProgressStore()
        let viewModel = makeViewModel(progressStore: progressStore)

        let isFinished = await viewModel.finishTask()

        #expect(isFinished)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isFinishingTask == false)
        #expect(progressStore.progress == nil)
    }

    @Test
    func finishTaskFailsWithErrorMessage() async {
        let progressStore = makeProgressStore()
        let viewModel = makeViewModel(
            userId: failingUserId,
            progressStore: progressStore
        )

        let isFinished = await viewModel.finishTask()

        #expect(isFinished == false)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isFinishingTask == false)
        #expect(progressStore.progress != nil)
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
        userId: Int = 1,
        progressStore: ReturnsProgressStoreProtocol = ReturnsProgressStoreFake()
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
            taskService: ReturnsTaskServiceMock(),
            progressStore: progressStore
        )
    }

    private func makeProgressStore() -> ReturnsProgressStoreFake {
        ReturnsProgressStoreFake(
            progress: ReturnsProgress(
                sourceContainerId: "source",
                decisions: [1: .good],
                photos: [:],
                itemContainers: [1: "good"]
            )
        )
    }
}
