import Foundation
import Observation

@Observable
final class PickingTaskViewModel {
    private static let collectAllItemsCheatCode = 666

    private var pickingTask: PickingTask
    
    var allItemsCount: Int { pickingTask.allItems.count }
    var collectedItemsCount: Int { collectedItems.count }
    var skippedItemsCount: Int { skippedItems.count }
    private(set) var collectedItems: [Item] = []
    private(set) var skippedItems: [Item] = []
    var isPickingEnded: Bool { collectedItemsCount + skippedItemsCount == allItemsCount }
    
    var leftItems: [Item] {
        sortedByPlacement(pickingTask.allItems.filter {
            !collectedItems.contains($0) && !skippedItems.contains($0)
        })
    }

    var currentItem: Item? {
        leftItems.first
    }

    init(pickingTask: PickingTask) {
        self.pickingTask = pickingTask
    }

    func tryToCollect(scannedCode: String) throws {
        guard let itemId = Int(scannedCode) else {
            throw PickingTaskError.wrongId
        }
        try tryToCollect(itemId: itemId)
    }
    
    func tryToCollect(itemId: Int) throws {
        if itemId == Self.collectAllItemsCheatCode {
            collectedItems += leftItems
            return
        }

        guard !collectedItems.contains(where: { $0.id == itemId }) else {
            throw PickingTaskError.alreadyCollected
        }
        guard let currentItem else { return }

        if currentItem.id == itemId {
            collectedItems.append(currentItem)
        } else {
            throw PickingTaskError.wrongId
        }
    }

    func skipCurrentItem() {
        guard let currentItem else { return }
        skippedItems.append(currentItem)
    }
    
    func preloadImages() async {
        await withTaskGroup(of: Void.self) { group in
            for item in pickingTask.allItems {
                let url = item.imageUrl
                group.addTask {
                    do {
                        _ = try await URLSession.shared.data(from: url)
                    } catch {
                        print("Failed to load image:", error)
                    }
                }
            }
        }
    }
    
    private func sortedByPlacement(_ items: [Item]) -> [Item] {
        items.sorted { lhs, rhs in
            let lhsPlacement = lhs.placement ?? ""
            let rhsPlacement = rhs.placement ?? ""
            let placementComparison = lhsPlacement.localizedStandardCompare(rhsPlacement)

            if placementComparison == .orderedSame {
                return lhs.article.localizedStandardCompare(rhs.article) == .orderedAscending
            }

            return placementComparison == .orderedAscending
        }
    }
}
