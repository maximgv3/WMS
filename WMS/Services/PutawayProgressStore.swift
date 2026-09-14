import SwiftData

protocol PutawayProgressStoreProtocol: AnyObject {
    func load(for containerId: String) -> PutawayProgress?
    func save(_ progress: PutawayProgress)
    func clear()
}

final class PutawayProgressStore: PutawayProgressStoreProtocol {
    private var context: ModelContext? {
        ProgressDatabase.container?.mainContext
    }

    func load(for containerId: String) -> PutawayProgress? {
        guard let record = fetchRecord() else { return nil }
        guard record.containerId == containerId else {
            clear()
            return nil
        }

        return PutawayProgress(
            containerId: record.containerId,
            placedItems: record.placedItems
        )
    }

    func save(_ progress: PutawayProgress) {
        guard let context else { return }

        if let record = fetchRecord() {
            record.containerId = progress.containerId
            record.placedItems = progress.placedItems
        } else {
            let record = PutawayProgressRecord(
                containerId: progress.containerId,
                placedItems: progress.placedItems
            )
            context.insert(record)
        }

        try? context.save()
    }

    func clear() {
        guard let context, let record = fetchRecord() else { return }
        context.delete(record)
        try? context.save()
    }

    private func fetchRecord() -> PutawayProgressRecord? {
        guard let context else { return nil }
        return try? context.fetch(FetchDescriptor<PutawayProgressRecord>()).first
    }
}
