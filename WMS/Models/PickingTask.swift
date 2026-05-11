import Foundation

struct PickingTask: Identifiable, Sendable, Hashable {
    let id: UUID = UUID()
    let allItems: [Item]
}

enum PickingTaskError: Error {
    case wrongId
    case alreadyCollected
}
