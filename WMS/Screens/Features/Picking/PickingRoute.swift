import Foundation

enum PickingRoute: Hashable {
    case task(PickingTask)
    case finish([Item])
}
