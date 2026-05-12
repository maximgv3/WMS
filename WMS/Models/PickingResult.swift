import Foundation

nonisolated struct PickingResult: Hashable, Sendable {
    let collectedItems: [Item]
    let skippedItems: [Item]
    let replacements: [Item: Item]

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
