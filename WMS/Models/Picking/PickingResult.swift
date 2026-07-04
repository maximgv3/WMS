import Foundation

nonisolated struct PickingResult: Hashable, Sendable {
    let collectedItems: [Item]
    let skippedItems: [Item]
    let replacements: [Item: Int]

    var collectedCount: Int { collectedItems.count + replacements.count }
    var skippedCount: Int { skippedItems.count }
    var totalCount: Int { collectedCount + skippedCount }

    init(
        collectedItems: [Item],
        skippedItems: [Item],
        replacements: [Item: Int] = [:]
    ) {
        self.collectedItems = collectedItems
        self.skippedItems = skippedItems
        self.replacements = replacements
    }
}
