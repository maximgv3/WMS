import Foundation

nonisolated struct ReturnItem: Identifiable, Decodable, Sendable, Hashable {
    let item: Item
    let reason: String

    var id: Item.ID { item.id }
}
