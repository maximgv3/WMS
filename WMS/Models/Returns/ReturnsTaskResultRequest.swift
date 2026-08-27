import Foundation

struct ReturnsTaskResultRequest: Encodable {
    let userId: Int
    let skippedItemIds: [Int]
    let checks: [ReturnCheck]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case skippedItemIds = "skipped_item_ids"
        case checks
    }
}

struct ReturnCheck: Encodable {
    let itemId: Int
    let decision: String

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case decision
    }
}
