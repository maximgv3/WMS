import Foundation

struct PickingTaskResultRequest: Encodable {
    let userId: Int
    let collectedItemIds: [Int]
    let skippedItemIds: [Int]
    let replacements: [Replacement]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case collectedItemIds = "collected_item_ids"
        case skippedItemIds = "skipped_item_ids"
        case replacements
    }
}

struct Replacement: Encodable {
    let originalItemId: Int
    let replacementId: Int
    
    enum CodingKeys: String, CodingKey {
        case originalItemId = "original_item_id"
        case replacementId = "replacement_id"
    }
}
