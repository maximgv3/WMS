import SwiftData

@Model
final class PutawayProgressRecord {
    var containerId: String
    var placedItems: [Item.ID: StorageCell.ID]

    init(
        containerId: String,
        placedItems: [Item.ID: StorageCell.ID]
    ) {
        self.containerId = containerId
        self.placedItems = placedItems
    }
}
