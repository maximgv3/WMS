import Foundation

nonisolated struct ReturnItem: Identifiable, Decodable, Sendable, Hashable {
    let item: Item
    let reason: String

    var id: Item.ID { item.id }

    var displayTitle: String {
        guard let detail = item.size ?? item.color ?? item.brand else {
            return item.title
        }
        return item.title + ", " + detail
    }
}
