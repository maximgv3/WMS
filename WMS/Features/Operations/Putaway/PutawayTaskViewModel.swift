import Foundation
import Observation

@Observable
final class PutawayTaskViewModel {
    
    let task: PutawayTask
    let service: PutawayTaskServiceProtocol
    
    private(set) var currentCell: StorageCell?
    private(set) var placedItems: [Item : StorageCell.ID] = [:]
    private(set) var lastPlacedItem: Item?
    private(set) var lastError: PutawayError?
    
    var currentCellItems: [Item] {
        guard let currentCell else { return [] }
        return task.items.filter { placedItems[$0] == currentCell.id }
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
            lastError = error as? PutawayError // Only PutawayError is thrown above
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
    
    private func processCellCode(_ cellId: String) throws {
        guard currentCell == nil else { throw PutawayError.notAnItem }
        currentCell = StorageCell(id: cellId)
    }
    
    private func processItemIdCode(_ itemId: String) throws {
        guard let currentCell else { throw PutawayError.notACell }
        guard let id = Int(itemId) else { throw PutawayError.notAnItem }
        guard let item = task.items.first(where: { $0.id == id }) else { throw PutawayError.itemNotInTask }
        if placedItems[item] == currentCell.id { return }
        guard !isCurrentCellFull else { throw PutawayError.cellIsFull }
        placedItems[item] = currentCell.id
        lastPlacedItem = item
    }
    
    private func isCellCode(_ code: String) -> Bool {
        code.filter({ $0 == "." }).count == 5 // Cell code contains 5 "." separators
    }
}
