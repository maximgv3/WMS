import Foundation
import Observation

@Observable
final class PickingTaskViewModel {
    private var pickingTask: PickingTask

    var leftItems: [Item] {
        sortedByPlacement(pickingTask.allItems.filter {
            !pickingTask.collectedItems.contains($0)
        })
    }

    var currentItem: Item? {
        leftItems.first
    }

    init(pickingTask: PickingTask) {
        self.pickingTask = pickingTask
    }

    func tryToCollect(itemId: Int) throws {
        guard !pickingTask.collectedItems.contains(where: { $0.id == itemId }) else {
            throw PickingTaskError.alreadyCollected
        }
        guard let currentItem else { return }

        if currentItem.id == itemId {
            pickingTask.collectedItems.append(currentItem)
        } else {
            throw PickingTaskError.wrongId
        }
    }

    private func sortedByPlacement(_ items: [Item]) -> [Item] {
        items.sorted { ($0.placement ?? "") < ($1.placement ?? "") }
    }
}
