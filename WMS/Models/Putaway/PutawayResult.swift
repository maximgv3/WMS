import Foundation

nonisolated struct PutawayResult: Hashable, Sendable {
    let placedItems: [Item.ID: StorageCell.ID]
}
