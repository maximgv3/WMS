@testable import WMS

final class PutawayProgressStoreFake: PutawayProgressStoreProtocol {
    var progress: PutawayProgress?

    init(progress: PutawayProgress? = nil) {
        self.progress = progress
    }

    func load(for containerId: String) -> PutawayProgress? {
        guard let progress else { return nil }
        guard progress.containerId == containerId else {
            self.progress = nil
            return nil
        }
        return progress
    }

    func save(_ progress: PutawayProgress) {
        self.progress = progress
    }

    func clear() {
        progress = nil
    }
}
