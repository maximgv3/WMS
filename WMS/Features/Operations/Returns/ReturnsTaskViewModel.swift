import Foundation
import Observation

@Observable
final class ReturnsTaskViewModel {

    let task: ReturnsTask
    let service: ReturnsTaskServiceProtocol

    private(set) var containers: ReturnsContainers
    private(set) var rebindingSlot: ReturnContainerSlot?
    private(set) var currentItem: ReturnItem?
    private(set) var decisions: [Item.ID: ReturnDecision] = [:]
    private(set) var photos: [Item.ID: Data] = [:]
    private(set) var itemContainers: [Item.ID: String] = [:]
    private(set) var lastError: ReturnsError?
    private var decisionOrder: [ReturnItem] = [] // Newest first

    var checkedItemsCount: Int { decisions.count }
    var allItemsCount: Int { task.items.count }
    var leftItems: [ReturnItem] { task.items.filter { decisions[$0.id] == nil } }
    var checkedItems: [ReturnItem] { decisionOrder }
    var isAllItemsChecked: Bool { leftItems.isEmpty }

    var result: ReturnsResult {
        ReturnsResult(
            decisions: decisions,
            photos: photos,
            containers: itemContainers,
            sourceContainerId: task.container.id,
            skippedItemIds: leftItems.map(\.id)
        )
    }

    init(
        task: ReturnsTask,
        containers: ReturnsContainers,
        service: ReturnsTaskServiceProtocol
    ) {
        self.task = task
        self.containers = containers
        self.service = service
    }

    func processCode(_ code: String) {
        do {
            if let rebindingSlot {
                try bind(code, to: rebindingSlot)
                self.rebindingSlot = nil
            } else {
                try selectItem(code)
            }
            lastError = nil
        } catch {
            lastError = error
        }
    }

    func startRebinding(_ slot: ReturnContainerSlot) {
        rebindingSlot = rebindingSlot == slot ? nil : slot
        lastError = nil
    }

    func decide(_ decision: ReturnDecision, photo: Data? = nil) {
        guard let currentItem else { return }
        if decision.requiresPhoto && photo == nil { return }
        
        decisions[currentItem.id] = decision
        photos[currentItem.id] = photo
        itemContainers[currentItem.id] = containers[decision.containerSlot]
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
    
    private func bind(_ code: String, to slot: ReturnContainerSlot)
        throws(ReturnsError)
    {
        guard ReturnsContainer.isContainerCode(code) else {
            throw ReturnsError.notAContainer
        }
        let otherSlots = ReturnContainerSlot.allCases.filter { $0 != slot }
        guard code != task.container.id,
            !otherSlots.contains(where: { containers[$0] == code })
        else {
            throw ReturnsError.containerAlreadyUsed
        }

        switch slot {
        case .good:
            containers = ReturnsContainers(
                good: code,
                inspection: containers.inspection
            )
        case .inspection:
            containers = ReturnsContainers(
                good: containers.good,
                inspection: code
            )
        }
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
