@testable import WMS

nonisolated final class PickingProgressStoreFake: PickingProgressStoreProtocol {
    var progress: PickingProgress?

    init(progress: PickingProgress? = nil) {
        self.progress = progress
    }

    func load() -> PickingProgress? {
        progress
    }

    func save(_ progress: PickingProgress) {
        self.progress = progress
    }

    func clear() {
        progress = nil
    }
}
