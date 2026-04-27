import Foundation

struct PickingTask: Identifiable, Sendable, Hashable {
    let id: UUID = UUID()
    let allItems: [Item]
    var collectedItems: [Item] = []
}

enum PickingTaskError: Error {
    case wrongId
    case alreadyCollected
}
