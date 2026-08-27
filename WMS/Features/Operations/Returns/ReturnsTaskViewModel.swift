import Foundation
import Observation

@Observable
final class ReturnsTaskViewModel {

    let task: ReturnsTask
    let service: ReturnsTaskServiceProtocol

    private(set) var currentItem: ReturnItem?
    private(set) var decisions: [Item.ID: ReturnDecision] = [:]
    private(set) var lastError: ReturnsError?
    private var decisionOrder: [ReturnItem] = [] // Newest first

    var checkedItemsCount: Int { decisions.count }
    var allItemsCount: Int { task.items.count }
    var leftItems: [ReturnItem] { task.items.filter { decisions[$0.id] == nil } }
    var checkedItems: [ReturnItem] { decisionOrder }
    var isAllItemsChecked: Bool { leftItems.isEmpty }

    var result: ReturnsResult {
        ReturnsResult(decisions: decisions, skippedItemIds: leftItems.map(\.id))
    }

    init(task: ReturnsTask, service: ReturnsTaskServiceProtocol) {
        self.task = task
        self.service = service
    }

    func processCode(_ code: String) {
        do {
            try selectItem(code)
            lastError = nil
        } catch {
            lastError = error
        }
    }

    func decide(_ decision: ReturnDecision) {
        guard let currentItem else { return }
        decisions[currentItem.id] = decision
        markAsLastChecked(currentItem)
        self.currentItem = nil
    }

    func preloadImages() async {
        await withTaskGroup(of: Void.self) { group in
            for returnItem in task.items {
                guard let url = returnItem.item.imageUrl else { continue }
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

    func clearCurrentItem() {
        currentItem = nil
    }

    func clearError() {
        lastError = nil
    }

    private func markAsLastChecked(_ returnItem: ReturnItem) {
        decisionOrder.removeAll { $0.id == returnItem.id }
        decisionOrder.insert(returnItem, at: 0)
    }

    private func selectItem(_ code: String) throws(ReturnsError) {
        guard currentItem == nil else { throw ReturnsError.decisionRequired }
        guard let id = Int(code) else { throw ReturnsError.notAnItem }
        guard let returnItem = task.items.first(where: { $0.id == id }) else {
            throw ReturnsError.itemNotInTask
        }

        currentItem = returnItem
    }
}
