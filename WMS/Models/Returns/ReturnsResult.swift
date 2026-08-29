import Foundation

nonisolated struct ReturnsResult: Hashable, Sendable {
    let decisions: [Item.ID: ReturnDecision]
    let photos: [Item.ID: Data]
    let containers: [Item.ID: String]
    let sourceContainerId: String
    let skippedItemIds: [Item.ID]

    func count(of decision: ReturnDecision) -> Int {
        decisions.values.filter { $0 == decision }.count
    }
}
