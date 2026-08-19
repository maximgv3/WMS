import Foundation
import Observation

@Observable
final class PutawayContainerViewModel {

    let container: PutawayContainer

    private(set) var lastError: PutawayError?

    init(container: PutawayContainer) {
        self.container = container
    }

    func processCode(_ code: String) {
        lastError = code == container.id ? nil : .wrongContainer
    }

    func clearError() {
        lastError = nil
    }
}
