import SwiftData

protocol ReturnsProgressStoreProtocol: AnyObject {
    func load(for sourceContainerId: String) -> ReturnsProgress?
    func save(_ progress: ReturnsProgress)
    func clear()
}

final class ReturnsProgressStore: ReturnsProgressStoreProtocol {
    private var context: ModelContext? {
        ProgressDatabase.container?.mainContext
    }

    func load(for sourceContainerId: String) -> ReturnsProgress? {
        guard let record = fetchRecord() else { return nil }
        guard record.sourceContainerId == sourceContainerId else {
            clear()
            return nil
        }

        let decisions = record.decisions.reduce(
            into: [Item.ID: ReturnDecision]()
        ) { result, element in
            guard let decision = ReturnDecision(rawValue: element.value) else {
                return
            }
            result[element.key] = decision
        }

        return ReturnsProgress(
            sourceContainerId: record.sourceContainerId,
            decisions: decisions,
            photos: record.photos,
            itemContainers: record.itemContainers
        )
    }

    func save(_ progress: ReturnsProgress) {
        guard let context else { return }
        let decisions = progress.decisions.mapValues(\.rawValue)

        if let record = fetchRecord() {
            record.sourceContainerId = progress.sourceContainerId
            record.decisions = decisions
            record.photos = progress.photos
            record.itemContainers = progress.itemContainers
        } else {
            let record = ReturnsProgressRecord(
                sourceContainerId: progress.sourceContainerId,
                decisions: decisions,
                photos: progress.photos,
                itemContainers: progress.itemContainers
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

    private func fetchRecord() -> ReturnsProgressRecord? {
        guard let context else { return nil }
        return try? context.fetch(FetchDescriptor<ReturnsProgressRecord>()).first
    }
}
