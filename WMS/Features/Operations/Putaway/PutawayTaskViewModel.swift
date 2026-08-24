import Foundation
import Observation

@Observable
final class PutawayTaskViewModel {
    
    let task: PutawayTask
    let service: PutawayTaskServiceProtocol
    
    private(set) var currentCell: StorageCell?
    private(set) var placedItems: [Item.ID : StorageCell.ID] = [:]
    private(set) var lastError: PutawayError?
    private var pendingForeignCode: String?
    private var placementOrder: [Item] = [] // Newest first

    var lastPlacedItem: Item? { placementOrder.first }

    var currentCellItems: [Item] {
        guard let currentCell else { return [] }
        return placementOrder.filter { placedItems[$0.id] == currentCell.id }
    }
    
    var currentCellItemsCount: Int {
        guard let currentCell else { return 0 }
        return placedItems.values.filter { $0 == currentCell.id }.count
    }

    var currentCellProgress: Double {
        guard currentCell != nil, task.cellCapacity > 0 else { return 0 }
        return Double(currentCellItemsCount) / Double(task.cellCapacity)
    }
    
    var isCurrentCellFull: Bool {
        currentCellItemsCount >= task.cellCapacity
    }
    
    var placedItemsCount: Int {
        task.items.filter { placedItems[$0.id] != nil }.count
    }
    
    var allItemsCount: Int { task.items.count }
    
    var leftItems: [Item] { task.items.filter { placedItems[$0.id] == nil } }
    var isAllItemsPlaced: Bool { leftItems.isEmpty }
    var result: PutawayResult { PutawayResult(placedItems: placedItems, skippedItemIds: leftItems.map(\.id)) }
    
    init(task: PutawayTask, service: PutawayTaskServiceProtocol) {
        self.task = task
        self.service = service
    }
    
    func processCode(_ code: String) {
        let confirmedCode = pendingForeignCode
        pendingForeignCode = nil

        do {
            if isCellCode(code) {
                try processCellCode(code)
            } else {
                try processItemIdCode(code, confirmedCode: confirmedCode)
            }
            lastError = nil
        } catch {
            lastError = error
        }
    }

    func clearError() {
        lastError = nil
        pendingForeignCode = nil
    }

    func preloadImages() async {
        await withTaskGroup(of: Void.self) { group in
            for item in task.items {
                guard let url = item.imageUrl else { continue }
                group.addTask {
                    do {
                        _ = try await URLSession.shared.data(from: url)
                    } catch {
                        print("Failed to load image:", error)
                    }
                }
            }
        }
    }

    func clearCurrentCell() {
        currentCell = nil
        pendingForeignCode = nil
    }

    private func processCellCode(_ cellId: String) throws(PutawayError) {
        guard currentCell == nil else { throw PutawayError.notAnItem }
        currentCell = StorageCell(id: cellId)
    }
    
    private func processItemIdCode(
        _ itemId: String,
        confirmedCode: String?
    ) throws(PutawayError) {
        guard let currentCell else { throw PutawayError.notACell }
        guard let id = Int(itemId) else { throw PutawayError.notAnItem }

        guard let item = task.items.first(where: { $0.id == id }) else {
            guard confirmedCode == itemId else {
                pendingForeignCode = itemId
                throw PutawayError.itemNotInTask
            }
            try place(unknownItem(id: id), in: currentCell)
            return
        }

        try place(item, in: currentCell)
    }

    private func place(_ item: Item, in cell: StorageCell) throws(PutawayError) {
        // Rescanning an item from this same cell isn't an error and skips the limit
        if placedItems[item.id] != cell.id {
            guard !isCurrentCellFull else { throw PutawayError.cellIsFull }
            placedItems[item.id] = cell.id
        }
        markAsLastPlaced(item)
    }

    private func unknownItem(id: Int) -> Item {
        Item(
            id: id,
            barcode: "",
            article: "",
            brand: nil,
            title: "Неизвестный товар",
            size: nil,
            color: nil,
            imageUrl: nil,
            placement: nil,
            price: 0,
            stock: 0
        )
    }

    private func markAsLastPlaced(_ item: Item) {
        placementOrder.removeAll { $0.id == item.id }
        placementOrder.insert(item, at: 0)
    }
    
    private func isCellCode(_ code: String) -> Bool {
        code.filter({ $0 == "." }).count == 5 // Cell code contains 5 "." separators
    }
}
