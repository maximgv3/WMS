@testable import WMS

final class ActiveTaskStoreFake: ActiveTaskStoreProtocol {
    var activeOperation: OperationType?
    private(set) var refreshCount = 0

    init(activeOperation: OperationType? = nil) {
        self.activeOperation = activeOperation
    }

    func refresh() {
        refreshCount += 1
    }
}
