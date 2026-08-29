import Foundation
import Testing

@testable import WMS

@MainActor
struct ReturnsTaskViewModelTests {

    @Test
    func itemCodeBecomesCurrentItem() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("123")

        #expect(viewModel.currentItem?.id == 123)
        #expect(viewModel.lastError == nil)
    }

    @Test
    func nonNumericCodeFailsWithNotAnItem() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("ABC-123")

        #expect(viewModel.lastError == .notAnItem)
        #expect(viewModel.currentItem == nil)
    }

    @Test
    func unknownItemIdFailsWithItemNotInTask() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("999")

        #expect(viewModel.lastError == .itemNotInTask)
        #expect(viewModel.currentItem == nil)
    }

    @Test
    func secondItemCodeIsRejectedWhileDecisionIsPending() {
        let viewModel = makeViewModel(ids: [123, 456])

        viewModel.processCode("123")
        viewModel.processCode("456")

        #expect(viewModel.lastError == .decisionRequired)
        #expect(viewModel.currentItem?.id == 123)
    }

    @Test
    func decisionIsStoredAndClearsCurrentItem() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("123")
        viewModel.decide(.defect, photo: Data())

        #expect(viewModel.decisions[123] == .defect)
        #expect(viewModel.currentItem == nil)
        #expect(viewModel.checkedItemsCount == 1)
    }

    @Test
    func decisionWithoutCurrentItemIsIgnored() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.decide(.good)

        #expect(viewModel.decisions.isEmpty)
    }

    @Test
    func decisionRequiringPhotoIsIgnoredWithoutPhoto() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("123")
        viewModel.decide(.defect)

        #expect(viewModel.decisions.isEmpty)
        #expect(viewModel.currentItem?.id == 123)
    }

    @Test
    func photoIsStoredWithTheDecision() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("123")
        viewModel.decide(.defect, photo: Data([1]))

        #expect(viewModel.photos[123] == Data([1]))
    }

    @Test
    func checkedItemCanBeScannedAgain() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("123")
        viewModel.decide(.good)
        viewModel.processCode("123")

        #expect(viewModel.lastError == nil)
        #expect(viewModel.currentItem?.id == 123)
        #expect(viewModel.checkedItemsCount == 1)
    }

    @Test
    func newDecisionReplacesTheOldOne() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("123")
        viewModel.decide(.good)
        viewModel.processCode("123")
        viewModel.decide(.defect, photo: Data())

        #expect(viewModel.decisions[123] == .defect)
        #expect(viewModel.checkedItemsCount == 1)
    }

    @Test
    func newPhotoReplacesTheOldOne() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("123")
        viewModel.decide(.defect, photo: Data([1]))
        viewModel.processCode("123")
        viewModel.decide(.defect, photo: Data([2]))

        #expect(viewModel.photos[123] == Data([2]))
    }

    @Test
    func decisionWithoutPhotoRemovesTheOldPhoto() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("123")
        viewModel.decide(.defect, photo: Data([1]))
        viewModel.processCode("123")
        viewModel.decide(.good)

        #expect(viewModel.photos[123] == nil)
        #expect(viewModel.decisions[123] == .good)
    }

    @Test
    func checkedItemsAreOrderedNewestFirst() {
        let viewModel = makeViewModel(ids: [123, 456])

        viewModel.processCode("123")
        viewModel.decide(.good)
        viewModel.processCode("456")
        viewModel.decide(.defect, photo: Data())

        #expect(viewModel.checkedItems.map(\.id) == [456, 123])
    }

    @Test
    func redecidingMovesItemToTheFrontWithoutDuplicating() {
        let viewModel = makeViewModel(ids: [123, 456])

        viewModel.processCode("123")
        viewModel.decide(.good)
        viewModel.processCode("456")
        viewModel.decide(.defect, photo: Data())
        viewModel.processCode("123")
        viewModel.decide(.wrongItem, photo: Data())

        #expect(viewModel.checkedItems.map(\.id) == [123, 456])
        #expect(viewModel.decisions[123] == .wrongItem)
    }

    @Test
    func checkedItemLeavesTheItemsLeft() {
        let viewModel = makeViewModel(ids: [123, 456])

        viewModel.processCode("123")
        viewModel.decide(.good)

        #expect(viewModel.leftItems.map(\.id) == [456])
        #expect(viewModel.isAllItemsChecked == false)
    }

    @Test
    func allItemsCheckedWhenEveryItemHasDecision() {
        let viewModel = makeViewModel(ids: [123, 456])

        viewModel.processCode("123")
        viewModel.decide(.good)
        viewModel.processCode("456")
        viewModel.decide(.wrongItem, photo: Data())

        #expect(viewModel.isAllItemsChecked)
        #expect(viewModel.result.decisions == [123: .good, 456: .wrongItem])
        #expect(viewModel.result.skippedItemIds.isEmpty)
    }

    @Test
    func resultKeepsUncheckedItemsAsSkipped() {
        let viewModel = makeViewModel(ids: [123, 456])

        viewModel.processCode("123")
        viewModel.decide(.good)

        #expect(viewModel.result.skippedItemIds == [456])
        #expect(viewModel.result.count(of: .good) == 1)
        #expect(viewModel.result.count(of: .defect) == 0)
    }

    @Test
    func resultKeepsPhotosOfCheckedItems() {
        let viewModel = makeViewModel(ids: [123, 456])

        viewModel.processCode("123")
        viewModel.decide(.defect, photo: Data([1]))
        viewModel.processCode("456")
        viewModel.decide(.good)

        #expect(viewModel.result.photos == [123: Data([1])])
    }

    @Test
    func clearCurrentItemAllowsScanningAnotherItem() {
        let viewModel = makeViewModel(ids: [123, 456])

        viewModel.processCode("123")
        viewModel.clearCurrentItem()
        viewModel.processCode("456")

        #expect(viewModel.currentItem?.id == 456)
        #expect(viewModel.lastError == nil)
    }

    @Test
    func clearErrorResetsLastError() {
        let viewModel = makeViewModel(ids: [123])

        viewModel.processCode("999")
        viewModel.clearError()

        #expect(viewModel.lastError == nil)
    }

    private func makeReturnItem(id: Int) -> ReturnItem {
        ReturnItem(
            item: Item(
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
            ),
            reason: ""
        )
    }

    private func makeViewModel(ids: [Int]) -> ReturnsTaskViewModel {
        ReturnsTaskViewModel(
            task: ReturnsTask(items: ids.map(makeReturnItem)),
            service: ReturnsTaskServiceMock()
        )
    }
}
