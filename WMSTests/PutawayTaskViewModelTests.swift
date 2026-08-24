import Foundation
import Testing

@testable import WMS

@MainActor
struct PutawayTaskViewModelTests {

    // Cell codes contain exactly 5 "." separators
    private let cellA = "01.02.03.04.05.06"
    private let cellB = "01.02.03.04.05.07"

    @Test
    func cellCodeBecomesCurrentCell() {
        let viewModel = makeViewModel(items: [makeItem()])

        viewModel.processCode(cellA)

        #expect(viewModel.currentCell?.id == cellA)
        #expect(viewModel.lastError == nil)
    }

    @Test
    func itemScanWithoutCellFailsWithNotACell() {
        let item = makeItem()
        let viewModel = makeViewModel(items: [item])

        viewModel.processCode("\(item.id)")

        #expect(viewModel.lastError == .notACell)
        #expect(viewModel.placedItems.isEmpty)
    }

    @Test
    func secondCellCodeIsRejectedWhileCellIsActive() {
        let viewModel = makeViewModel(items: [makeItem()])

        viewModel.processCode(cellA)
        viewModel.processCode(cellB)

        #expect(viewModel.lastError == .notAnItem)
        #expect(viewModel.currentCell?.id == cellA)
    }

    @Test
    func nonNumericCodeFailsWithNotAnItem() {
        let viewModel = makeViewModel(items: [makeItem()])

        viewModel.processCode(cellA)
        viewModel.processCode("ABC-123")

        #expect(viewModel.lastError == .notAnItem)
        #expect(viewModel.placedItems.isEmpty)
    }

    @Test
    func unknownItemIdFailsWithItemNotInTask() {
        let viewModel = makeViewModel(items: [makeItem(id: 123)])

        viewModel.processCode(cellA)
        viewModel.processCode("999")

        #expect(viewModel.lastError == .itemNotInTask)
        #expect(viewModel.placedItems.isEmpty)
    }

    @Test
    func itemScanPlacesItemIntoCurrentCell() {
        let item = makeItem()
        let viewModel = makeViewModel(items: [item])

        viewModel.processCode(cellA)
        viewModel.processCode("\(item.id)")

        #expect(viewModel.lastError == nil)
        #expect(viewModel.placedItems == [item.id: cellA])
        #expect(viewModel.currentCellItemsCount == 1)
        #expect(viewModel.lastPlacedItem == item)
        #expect(viewModel.leftItems.isEmpty)
        #expect(viewModel.isAllItemsPlaced)
    }

    @Test
    func fullCellRejectsAnotherItem() {
        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)
        let viewModel = makeViewModel(items: [item1, item2], cellCapacity: 1)

        viewModel.processCode(cellA)
        viewModel.processCode("\(item1.id)")
        viewModel.processCode("\(item2.id)")

        #expect(viewModel.lastError == .cellIsFull)
        #expect(viewModel.placedItems == [item1.id: cellA])
        #expect(viewModel.isCurrentCellFull)
        #expect(viewModel.leftItems == [item2])
    }

    @Test
    func rescanningItemFromTheSameFullCellIsNotAnError() {
        let item = makeItem()
        let viewModel = makeViewModel(items: [item], cellCapacity: 1)

        viewModel.processCode(cellA)
        viewModel.processCode("\(item.id)")
        viewModel.processCode("\(item.id)")

        #expect(viewModel.lastError == nil)
        #expect(viewModel.placedItems == [item.id: cellA])
        #expect(viewModel.currentCellItemsCount == 1)
    }

    @Test
    func cellItemsAreOrderedNewestFirst() {
        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)
        let viewModel = makeViewModel(items: [item1, item2])

        viewModel.processCode(cellA)
        viewModel.processCode("\(item1.id)")
        viewModel.processCode("\(item2.id)")

        #expect(viewModel.lastPlacedItem == item2)
        #expect(viewModel.currentCellItems == [item2, item1])
    }

    @Test
    func rescanningItemMovesItToTheFrontWithoutDuplicating() {
        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)
        let viewModel = makeViewModel(items: [item1, item2])

        viewModel.processCode(cellA)
        viewModel.processCode("\(item1.id)")
        viewModel.processCode("\(item2.id)")
        viewModel.processCode("\(item1.id)")

        #expect(viewModel.lastPlacedItem == item1)
        #expect(viewModel.currentCellItems == [item1, item2])
        #expect(viewModel.placedItemsCount == 2)
    }

    @Test
    func scanningItemInAnotherCellMovesItThere() {
        let item = makeItem()
        let viewModel = makeViewModel(items: [item])

        viewModel.processCode(cellA)
        viewModel.processCode("\(item.id)")
        viewModel.clearCurrentCell()
        viewModel.processCode(cellB)
        viewModel.processCode("\(item.id)")

        #expect(viewModel.placedItems == [item.id: cellB])
        #expect(viewModel.currentCellItemsCount == 1)
        #expect(viewModel.placedItemsCount == 1)
    }

    @Test
    func clearCurrentCellKeepsPlacementsAndRequiresNewCell() {
        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)
        let viewModel = makeViewModel(items: [item1, item2])

        viewModel.processCode(cellA)
        viewModel.processCode("\(item1.id)")
        viewModel.clearCurrentCell()

        #expect(viewModel.currentCell == nil)
        #expect(viewModel.currentCellItems.isEmpty)
        #expect(viewModel.currentCellItemsCount == 0)
        #expect(viewModel.currentCellProgress == 0)
        #expect(viewModel.placedItemsCount == 1)

        viewModel.processCode("\(item2.id)")

        #expect(viewModel.lastError == .notACell)
    }

    @Test
    func cellProgressFollowsCapacity() {
        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)
        let viewModel = makeViewModel(items: [item1, item2], cellCapacity: 2)

        viewModel.processCode(cellA)
        viewModel.processCode("\(item1.id)")

        #expect(viewModel.currentCellProgress == 0.5)
        #expect(viewModel.isCurrentCellFull == false)

        viewModel.processCode("\(item2.id)")

        #expect(viewModel.currentCellProgress == 1)
        #expect(viewModel.isCurrentCellFull)
    }

    @Test
    func successfulScanClearsPreviousError() {
        let item = makeItem()
        let viewModel = makeViewModel(items: [item])

        viewModel.processCode("\(item.id)")
        #expect(viewModel.lastError == .notACell)

        viewModel.processCode(cellA)
        #expect(viewModel.lastError == nil)
    }

    @Test
    func clearErrorResetsLastError() {
        let viewModel = makeViewModel(items: [makeItem()])

        viewModel.processCode("123")
        viewModel.clearError()

        #expect(viewModel.lastError == nil)
    }

    @Test
    func resultContainsPlacementsAndUnplacedItems() {
        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)
        let item3 = makeItem(id: 3)
        let viewModel = makeViewModel(items: [item1, item2, item3])

        viewModel.processCode(cellA)
        viewModel.processCode("\(item1.id)")
        viewModel.processCode("\(item2.id)")

        #expect(viewModel.result.placedItems == [item1.id: cellA, item2.id: cellA])
        #expect(viewModel.result.skippedItemIds == [item3.id])
        #expect(viewModel.allItemsCount == 3)
        #expect(viewModel.isAllItemsPlaced == false)
    }

    // MARK: - Items outside the task

    @Test
    func foreignItemIsRejectedOnFirstScan() {
        let viewModel = makeViewModel(items: [makeItem()])

        viewModel.processCode(cellA)
        viewModel.processCode("999")

        #expect(viewModel.lastError == .itemNotInTask)
        #expect(viewModel.placedItems.isEmpty)
    }

    @Test
    func foreignItemIsPlacedOnSecondScan() {
        let viewModel = makeViewModel(items: [makeItem()])

        viewModel.processCode(cellA)
        viewModel.processCode("999")
        viewModel.processCode("999")

        #expect(viewModel.lastError == nil)
        #expect(viewModel.placedItems[999] == cellA)
        #expect(viewModel.lastPlacedItem?.title == "Неизвестный товар")
    }

    @Test
    func foreignItemNeedsTwoScansInARow() {
        let item = makeItem()
        let viewModel = makeViewModel(items: [item])

        viewModel.processCode(cellA)
        viewModel.processCode("999")
        viewModel.processCode("\(item.id)")
        viewModel.processCode("999")

        #expect(viewModel.lastError == .itemNotInTask)
        #expect(viewModel.placedItems[999] == nil)
    }

    @Test
    func clearingErrorCancelsForeignConfirmation() {
        let viewModel = makeViewModel(items: [makeItem()])

        viewModel.processCode(cellA)
        viewModel.processCode("999")
        viewModel.clearError()
        viewModel.processCode("999")

        #expect(viewModel.lastError == .itemNotInTask)
        #expect(viewModel.placedItems.isEmpty)
    }

    @Test
    func foreignItemTakesUpCellCapacity() {
        let item = makeItem()
        let viewModel = makeViewModel(items: [item], cellCapacity: 1)

        viewModel.processCode(cellA)
        viewModel.processCode("999")
        viewModel.processCode("999")
        viewModel.processCode("\(item.id)")

        #expect(viewModel.lastError == .cellIsFull)
        #expect(viewModel.currentCellItemsCount == 1)
    }

    @Test
    func foreignItemIsNotCountedAsTaskProgress() {
        let item = makeItem()
        let viewModel = makeViewModel(items: [item])

        viewModel.processCode(cellA)
        viewModel.processCode("999")
        viewModel.processCode("999")

        #expect(viewModel.placedItemsCount == 0)
        #expect(viewModel.isAllItemsPlaced == false)
        #expect(viewModel.currentCellItems.count == 1)
    }

    private func makeItem(id: Int = 123) -> Item {
        Item(
            id: id,
            barcode: "",
            article: "",
            brand: "",
            title: "",
            size: "",
            color: "",
            imageUrl: URL(string: "https://example.com/image.png")!,
            placement: "A1",
            price: 1000,
            stock: 5
        )
    }

    private func makeViewModel(
        items: [Item],
        cellCapacity: Int = 2
    ) -> PutawayTaskViewModel {
        PutawayTaskViewModel(
            task: PutawayTask(
                items: items,
                cellCapacity: cellCapacity,
                container: PutawayContainer(id: "", location: "")
            ),
            service: PutawayTaskServiceMock()
        )
    }
}
