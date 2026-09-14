import Foundation
import Observation

@Observable
final class PickingTaskViewModel {

    #if DEBUG
        static let collectAllItemsCheatCode = 666
    #endif

    private var pickingTask: PickingTask
    private var pickingTaskService: PickingTaskServiceProtocol
    private let progressStore: PickingProgressStoreProtocol

    var allItemsCount: Int { pickingTask.allItems.count }
    var collectedItemsCount: Int { collectedItems.count + replacements.count }
    var skippedItemsCount: Int { skippedItems.count }

    private(set) var collectedItems: [Item] = []
    private(set) var skippedItems: [Item] = []
    private(set) var replacements: [Item.ID: Int] = [:]  // Old item id : New item id
    var isPickingEnded: Bool {
        collectedItemsCount + skippedItemsCount == allItemsCount
    }

    var leftItems: [Item] {
        sortedByPlacement(
            pickingTask.allItems.filter { item in
                !collectedItems.contains { $0.id == item.id }
                    && !skippedItems.contains { $0.id == item.id }
                    && replacements[item.id] == nil
            }
        )
    }

    var currentItem: Item? {
        leftItems.first
    }

    init(
        pickingTask: PickingTask,
        pickingTaskService: PickingTaskServiceProtocol,
        progressStore: PickingProgressStoreProtocol
    ) {
        self.pickingTask = pickingTask
        self.pickingTaskService = pickingTaskService
        self.progressStore = progressStore

        restoreProgress()
    }

    func tryToCollect(scannedCode: String) throws {
        guard let itemId = Int(scannedCode) else {
            throw PickingTaskError.wrongId
        }
        try tryToCollect(itemId: itemId)
    }

    func tryToCollect(itemId: Int) throws {
        #if DEBUG
            if itemId == Self.collectAllItemsCheatCode {
                collectedItems += leftItems
                saveProgress()
                return
            }
        #endif
        guard !isCollectedOrReplacementIdAlreadyUsed(itemId) else {
            throw PickingTaskError.alreadyCollected
        }
        guard let currentItem else { return }

        if currentItem.id == itemId {
            collectedItems.append(currentItem)
            saveProgress()
        } else {
            throw PickingTaskError.wrongId
        }
    }

    func skipCurrentItem() {
        guard let currentItem else { return }
        skippedItems.append(currentItem)
        saveProgress()
    }

    func tryToReplace(replacementId: Int) async throws {
        guard let item = currentItem else { return }
        guard item.id != replacementId else {
            try tryToCollect(itemId: replacementId)
            return
        }
        guard !isCollectedOrReplacementIdAlreadyUsed(replacementId) else {
            throw PickingTaskError.alreadyCollected
        }
        if await pickingTaskService.checkIfIdAvailableForReplacement(
            id: item.id,
            replacementId: replacementId
        ) {
            guard currentItem?.id == item.id else {
                throw PickingTaskError.alreadyCollected
            }
            replacements[item.id] = replacementId
            saveProgress()
        } else {
            throw PickingTaskError.cantUseForReplacement
        }
    }

    func preloadImages() async {
        await withTaskGroup(of: Void.self) { group in
            for item in pickingTask.allItems {
                guard let url = item.imageUrl else { continue }
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

    private func restoreProgress() {
        guard let progress = progressStore.load() else { return }
        collectedItems = items(with: progress.collectedItemIds)
        skippedItems = items(with: progress.skippedItemIds)
        replacements = progress.replacements
    }

    private func saveProgress() {
        let progress = PickingProgress(
            collectedItemIds: collectedItems.map(\.id),
            skippedItemIds: skippedItems.map(\.id),
            replacements: replacements
        )

        progressStore.save(progress)
    }

    private func items(with ids: [Item.ID]) -> [Item] {
        ids.compactMap { id in
            guard let item = pickingTask.allItems.first(where: { $0.id == id }) else {
                print("⚠️ Saved Picking item \(id) is missing from the current task")
                return nil
            }

            return item
        }
    }

    private func isCollectedOrReplacementIdAlreadyUsed(_ itemId: Int) -> Bool {
        collectedItems.contains { $0.id == itemId }
            || replacements.values.contains(itemId)
    }

    private func sortedByPlacement(_ items: [Item]) -> [Item] {
        items.sorted { lhs, rhs in
            let lhsPlacement = lhs.placement ?? ""
            let rhsPlacement = rhs.placement ?? ""
            let placementComparison = lhsPlacement.localizedStandardCompare(
                rhsPlacement
            )

            if placementComparison == .orderedSame {
                return lhs.article.localizedStandardCompare(rhs.article)
                    == .orderedAscending
            }

            return placementComparison == .orderedAscending
        }
    }
}
