import Foundation
import Observation

@Observable
final class PickingTaskViewModel {
    static let collectAllItemsCheatCode = 666

    private var pickingTask: PickingTask
    private var pickingTaskService: PickingTaskServiceProtocol

    var allItemsCount: Int { pickingTask.allItems.count }
    var collectedItemsCount: Int { collectedItems.count + replacements.count }
    var skippedItemsCount: Int { skippedItems.count }

    private(set) var collectedItems: [Item] = []
    private(set) var skippedItems: [Item] = []
    private(set) var replacements: [Item: Int] = [:] // Old Item : New item id
    var isPickingEnded: Bool { collectedItemsCount + skippedItemsCount == allItemsCount }

    var leftItems: [Item] {
        sortedByPlacement(pickingTask.allItems.filter { item in
            !collectedItems.contains(item)
                && !skippedItems.contains(item)
                && !replacements.keys.contains(item)
        })
    }

    var currentItem: Item? {
        leftItems.first
    }

    init(pickingTask: PickingTask, pickingTaskService: PickingTaskServiceProtocol) {
        self.pickingTask = pickingTask
        self.pickingTaskService = pickingTaskService
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

        guard !isCollectedOrReplacementIdAlreadyUsed(itemId) else {
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

    func tryToReplace(replacementId: Int) async throws {
        guard let currentItem else { return }
        guard currentItem.id != replacementId else {
            try tryToCollect(itemId: replacementId)
            return
        }
        guard !isCollectedOrReplacementIdAlreadyUsed(replacementId) else {
            throw PickingTaskError.alreadyCollected
        }
        if await pickingTaskService.checkIfIdAvailableForReplacement(id: currentItem.id, replacementId: replacementId) {
            registerReplacement(replacementId: replacementId)
        } else {
            throw PickingTaskError.cantUseForReplacement
        }
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
    private func registerReplacement(replacementId: Int) {
        guard let currentItem else { return }
        replacements[currentItem] = replacementId
    }

    private func isCollectedOrReplacementIdAlreadyUsed(_ itemId: Int) -> Bool {
        collectedItems.contains { $0.id == itemId }
            || replacements.values.contains(itemId)
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
