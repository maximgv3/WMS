import Foundation
import SwiftData

@Model
final class ReturnsProgressRecord {
    var sourceContainerId: String
    var decisions: [Item.ID: String]
    var photos: [Item.ID: Data]
    var itemContainers: [Item.ID: String]

    init(
        sourceContainerId: String,
        decisions: [Item.ID: String],
        photos: [Item.ID: Data],
        itemContainers: [Item.ID: String]
    ) {
        self.sourceContainerId = sourceContainerId
        self.decisions = decisions
        self.photos = photos
        self.itemContainers = itemContainers
    }
}
