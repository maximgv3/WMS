import Foundation

nonisolated struct PickingTask: Identifiable, Sendable, Hashable {
    let id: UUID = UUID()
    let allItems: [Item]
}

nonisolated enum PickingTaskError: Error {
    case wrongId
    case alreadyCollected
    case cantUseForReplacement
}
