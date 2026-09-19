import Observation
import SwiftData

protocol ActiveTaskStoreProtocol: AnyObject {
    var activeOperation: OperationType? { get }

    func refresh()
}

@Observable
final class ActiveTaskStore: ActiveTaskStoreProtocol {

    private(set) var activeOperation: OperationType?

    private var context: ModelContext? {
        ProgressDatabase.container?.mainContext
    }

    init() {
        refresh()
    }

    func refresh() {
        if hasRecords(of: PutawayProgressRecord.self) {
            activeOperation = .putaway
        } else if hasRecords(of: PickingProgressRecord.self) {
            activeOperation = .picking
        } else if hasRecords(of: ReturnsProgressRecord.self) {
            activeOperation = .returns
        } else {
            activeOperation = nil
        }
    }

    private func hasRecords<Record: PersistentModel>(
        of type: Record.Type
    ) -> Bool {
        guard let context else { return false }
        let count = try? context.fetchCount(FetchDescriptor<Record>())
        return (count ?? 0) > 0
    }
}
