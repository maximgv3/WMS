nonisolated struct PutawayProgress: Sendable, Equatable {
    let containerId: String
    let placedItems: [Item.ID: StorageCell.ID]
}
