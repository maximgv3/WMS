import Testing
import Foundation
@testable import WMS

struct PickingTaskViewModelTests {
    @Test
    func correctItemIdCollectsCurrentItem() throws {
        let item = makeItem()
        let task = PickingTask(allItems: [item])
        let viewModel = PickingTaskViewModel(pickingTask: task)

        try viewModel.tryToCollect(itemId: item.id)

        #expect(viewModel.collectedItems.count == 1)
        #expect(viewModel.collectedItems == [item])
        #expect(viewModel.isPickingEnded)
    }

    @Test
    func wrongItemIdThrowsWrongId() throws {
        let item = makeItem()
        let task = PickingTask(allItems: [item])
        let viewModel = PickingTaskViewModel(pickingTask: task)

        #expect(throws: PickingTaskError.wrongId) { try viewModel.tryToCollect(itemId: -1) }
        #expect(viewModel.collectedItems.isEmpty)
        #expect(viewModel.collectedItemsCount == 0)
        #expect(viewModel.isPickingEnded == false)
    }

    @Test
    func alreadyCollectedIdThrowsAlreadyCollectedError() throws {
        let item1 = makeItem()
        let item2 = makeItem(id: 456)
        let task = PickingTask(allItems: [item1, item2])
        let viewModel = PickingTaskViewModel(pickingTask: task)
        try viewModel.tryToCollect(itemId: item1.id)

        #expect(throws: PickingTaskError.alreadyCollected) {
            try viewModel.tryToCollect(itemId: item1.id)
        }
        #expect(viewModel.collectedItemsCount == 1)
        #expect(viewModel.isPickingEnded == false)
    }

    @Test
    func pickingFinishesSuccessfully() throws {
        let task = PickingTask(allItems: [makeItem(), makeItem(id: 456), makeItem(id: 789)])
        let viewModel = PickingTaskViewModel(pickingTask: task)

        try viewModel.tryToCollect(itemId: 123)
        try viewModel.tryToCollect(itemId: 456)
        try viewModel.tryToCollect(itemId: 789)

        #expect(viewModel.isPickingEnded)
        #expect(viewModel.leftItems.isEmpty)
        #expect(viewModel.collectedItemsCount == 3)
    }

    @Test
    func skipCurrentItemMovesItemToSkippedAndEndsSingleItemTask() {
        let item = makeItem()
        let task = PickingTask(allItems: [item])
        let viewModel = PickingTaskViewModel(pickingTask: task)

        viewModel.skipCurrentItem()

        #expect(viewModel.skippedItems == [item])
        #expect(viewModel.skippedItemsCount == 1)
        #expect(viewModel.leftItems.isEmpty)
        #expect(viewModel.isPickingEnded)
    }

    @Test
    func cheatCodeCollectsOnlyLeftItems() throws {
        let item1 = makeItem(id: 123)
        let item2 = makeItem(id: 456)
        let item3 = makeItem(id: 789)
        let task = PickingTask(allItems: [item1, item2, item3])
        let viewModel = PickingTaskViewModel(pickingTask: task)
        let cheatCode = PickingTaskViewModel.collectAllItemsCheatCode

        viewModel.skipCurrentItem()

        try viewModel.tryToCollect(itemId: cheatCode)

        #expect(viewModel.skippedItems == [item1])
        #expect(viewModel.collectedItems == [item2, item3])
        #expect(viewModel.isPickingEnded)
    }

    private func makeItem(id: Int = 123) -> Item {
        Item(
            id: id,
            barcode: "\(id)",
            article: "TEST-\(id)",
            brand: "Nike",
            title: "Test item",
            size: "M",
            color: "Black",
            imageUrl: URL(string: "https://example.com/image.png")!,
            placement: "A1",
            price: 1000,
            stock: 5
        )
    }
}
