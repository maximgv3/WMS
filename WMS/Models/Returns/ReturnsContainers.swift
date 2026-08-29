import Foundation

nonisolated struct ReturnsContainers: Sendable, Hashable {
    let good: String
    let inspection: String

    subscript(slot: ReturnContainerSlot) -> String {
        switch slot {
        case .good:
            good
        case .inspection:
            inspection
        }
    }
}
