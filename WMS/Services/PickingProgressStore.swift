import SwiftData

protocol PickingProgressStoreProtocol: AnyObject {
    func load() -> PickingProgress?
    func save(_ progress: PickingProgress)
    func clear()
}

final class PickingProgressStore: PickingProgressStoreProtocol {

    private var context: ModelContext? {
        ProgressDatabase.container?.mainContext
    }

    func load() -> PickingProgress? {
        guard let record = fetchRecord() else { return nil }

        return PickingProgress(
            collectedItemIds: record.collectedItemIds,
            skippedItemIds: record.skippedItemIds,
            replacements: record.replacements
        )
    }

    func save(_ progress: PickingProgress) {
        guard let context else { return }

        if let record = fetchRecord() {
            record.collectedItemIds = progress.collectedItemIds
            record.skippedItemIds = progress.skippedItemIds
            record.replacements = progress.replacements
        } else {
            let record = PickingProgressRecord(
                collectedItemIds: progress.collectedItemIds,
                skippedItemIds: progress.skippedItemIds,
                replacements: progress.replacements
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

    private func fetchRecord() -> PickingProgressRecord? {
        guard let context else { return nil }
        return try? context.fetch(FetchDescriptor<PickingProgressRecord>()).first
    }
}
