nonisolated struct PickingProgress: Sendable, Equatable {

    let collectedItemIds: [Item.ID]
    let skippedItemIds: [Item.ID]
    let replacements: [Item.ID: Int]

}
