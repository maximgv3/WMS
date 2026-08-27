import Foundation

nonisolated struct ReturnsResult: Hashable, Sendable {
    let decisions: [Item.ID: ReturnDecision]
    let skippedItemIds: [Item.ID]

    func count(of decision: ReturnDecision) -> Int {
        decisions.values.filter { $0 == decision }.count
    }
}
