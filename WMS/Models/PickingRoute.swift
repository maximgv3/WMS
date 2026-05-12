import Foundation

nonisolated enum PickingRoute: Hashable {
    case task(PickingTask)
    case finish(PickingResult)
}
