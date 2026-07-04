import Foundation

nonisolated struct PickingTask: Decodable, Sendable, Hashable {
    let allItems: [Item]

    init(allItems: [Item]) {
        self.allItems = allItems
    }

    enum CodingKeys: String, CodingKey {
        case allItems = "all_items"
    }
}

nonisolated enum PickingTaskError: Error {
    case wrongId
    case alreadyCollected
    case cantUseForReplacement
}
