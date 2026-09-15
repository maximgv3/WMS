@testable import WMS

final class ReturnsProgressStoreFake: ReturnsProgressStoreProtocol {
    var progress: ReturnsProgress?

    init(progress: ReturnsProgress? = nil) {
        self.progress = progress
    }

    func load(for sourceContainerId: String) -> ReturnsProgress? {
        guard let progress else { return nil }
        guard progress.sourceContainerId == sourceContainerId else {
            self.progress = nil
            return nil
        }
        return progress
    }

    func save(_ progress: ReturnsProgress) {
        self.progress = progress
    }

    func clear() {
        progress = nil
    }
}
