import Foundation

nonisolated enum OperationType: String, CaseIterable, Identifiable {
    case putaway
    case picking
    case returns

    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .putaway:
            .operationsPutaway
        case .picking:
            .operationsPicking
        case .returns:
            .operationsReturnsInspection
        }
    }
    var iconName: String {
        switch self {
        case .putaway:
            "tray.and.arrow.down"
        case .picking:
            "cart"
        case .returns:
            "shippingbox.and.arrow.backward"
        }
    }
    var fetchErrorTitle: LocalizedStringResource {
        switch self {
        case .putaway:
            .operationsCouldNotRetrieveTheTask
        case .picking:
            .operationsPickingListFetchFailed
        case .returns:
            .operationsCouldNotRetrieveTheTask
        }
    }

    enum WorkRoute: Hashable {
        case picking(PickingRoute)
        case putaway(PutawayRoute)
        case returns(ReturnsRoute)
    }
}
