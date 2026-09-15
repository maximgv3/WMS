import Foundation

nonisolated struct ReturnsProgress: Sendable, Equatable {
    let sourceContainerId: String
    let decisions: [Item.ID: ReturnDecision]
    let photos: [Item.ID: Data]
    let itemContainers: [Item.ID: String]
}
