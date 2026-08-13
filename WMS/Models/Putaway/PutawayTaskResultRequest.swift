import Foundation

struct PutawayTaskResultRequest: Encodable {
    let userId: Int
    let skippedItemIds: [Int]
    let placements: [Placement]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case skippedItemIds = "skipped_item_ids"
        case placements
    }
}

struct Placement: Encodable {
    let itemId: Int
    let cell: StorageCell.ID

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case cell
    }
}
