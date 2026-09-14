import SwiftData

@Model
final class PickingProgressRecord {
    var collectedItemIds: [Item.ID]
    var skippedItemIds: [Item.ID]
    var replacements: [Item.ID: Int]

    init(collectedItemIds: [Item.ID], skippedItemIds: [Item.ID], replacements: [Item.ID : Int]) {
        self.collectedItemIds = collectedItemIds
        self.skippedItemIds = skippedItemIds
        self.replacements = replacements
    }
}
