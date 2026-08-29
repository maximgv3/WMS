import Foundation
import Observation

@Observable
final class ReturnsContainersViewModel {

    let container: ReturnsContainer

    private(set) var isContainerScanned = false
    private(set) var boundContainers: [ReturnContainerSlot: String] = [:]
    private(set) var lastError: ReturnsError?

    var nextSlot: ReturnContainerSlot? {
        ReturnContainerSlot.allCases.first { boundContainers[$0] == nil }
    }

    var containers: ReturnsContainers? {
        guard let good = boundContainers[.good],
            let inspection = boundContainers[.inspection]
        else {
            return nil
        }
        return ReturnsContainers(good: good, inspection: inspection)
    }

    init(container: ReturnsContainer) {
        self.container = container
    }

    func processCode(_ code: String) {
        do {
            try scan(code)
            lastError = nil
        } catch {
            lastError = error
        }
    }

    func clearError() {
        lastError = nil
    }

    private func scan(_ code: String) throws(ReturnsError) {
        guard isContainerScanned else {
            guard code == container.id else { throw ReturnsError.wrongContainer }
            isContainerScanned = true
            return
        }
        guard let slot = nextSlot else { return }
        guard ReturnsContainer.isContainerCode(code) else {
            throw ReturnsError.notAContainer
        }
        guard code != container.id, !boundContainers.values.contains(code) else {
            throw ReturnsError.containerAlreadyUsed
        }

        boundContainers[slot] = code
    }
}
