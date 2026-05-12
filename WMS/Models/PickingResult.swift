import Foundation

nonisolated struct PickingResult: Hashable, Sendable {
    let collectedItems: [Item]
    let skippedItems: [Item]
    let replacements: [Item: Item]

    var collectedCount: Int { collectedItems.count }
    var skippedCount: Int { skippedItems.count }
    var totalCount: Int { collectedItems.count + skippedItems.count }

    init(
        collectedItems: [Item],
        skippedItems: [Item],
        replacements: [Item: Item] = [:]
    ) {
        self.collectedItems = collectedItems
        self.skippedItems = skippedItems
        self.replacements = replacements
    }
}
