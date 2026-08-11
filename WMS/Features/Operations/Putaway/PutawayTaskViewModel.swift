import Foundation
import Observation

@Observable
final class PutawayTaskViewModel {
    
    let task: PutawayTask
    let service: PutawayTaskServiceProtocol
    
    private(set) var currentCell: StorageCell?
    private(set) var placedItems: [Item : StorageCell.ID] = [:]
    private(set) var lastError: PutawayError?
    private var placementOrder: [Item] = [] // Newest first

    var lastPlacedItem: Item? { placementOrder.first }

    var currentCellItems: [Item] {
        guard let currentCell else { return [] }
        return placementOrder.filter { placedItems[$0] == currentCell.id }
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
        placedItems.count
    }
    
    var allItemsCount: Int { task.items.count }
    
    var leftItems: [Item] { task.items.filter { placedItems[$0] == nil } }
    var isPutawayEnded: Bool { leftItems.isEmpty }
    var result: PutawayResult { PutawayResult(placedItems: placedItems) }
    
    init(task: PutawayTask, service: PutawayTaskServiceProtocol) {
        self.task = task
        self.service = service
    }
    
    func processCode(_ code: String) {
        do {
            if isCellCode(code) {
                try processCellCode(code)
            } else {
                try processItemIdCode(code)
            }
            lastError = nil
        } catch {
            lastError = error
        }
    }

    func clearError() {
        lastError = nil
    }

    func preloadImages() async {
        await withTaskGroup(of: Void.self) { group in
            for item in task.items {
                let url = item.imageUrl
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
    }
    
    private func processCellCode(_ cellId: String) throws(PutawayError) {
        guard currentCell == nil else { throw PutawayError.notAnItem }
        currentCell = StorageCell(id: cellId)
    }
    
    private func processItemIdCode(_ itemId: String) throws(PutawayError) {
        guard let currentCell else { throw PutawayError.notACell }
        guard let id = Int(itemId) else { throw PutawayError.notAnItem }
        guard let item = task.items.first(where: { $0.id == id }) else { throw PutawayError.itemNotInTask }
        // Rescanning an item from this same cell isn't an error and skips the limit
        if placedItems[item] != currentCell.id {
            guard !isCurrentCellFull else { throw PutawayError.cellIsFull }
            placedItems[item] = currentCell.id
        }
        markAsLastPlaced(item)
    }

    private func markAsLastPlaced(_ item: Item) {
        placementOrder.removeAll { $0 == item }
        placementOrder.insert(item, at: 0)
    }
    
    private func isCellCode(_ code: String) -> Bool {
        code.filter({ $0 == "." }).count == 5 // Cell code contains 5 "." separators
    }
}
