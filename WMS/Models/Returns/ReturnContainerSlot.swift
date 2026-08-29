import Foundation

nonisolated enum ReturnContainerSlot: String, CaseIterable, Identifiable,
    Sendable, Hashable
{
    case good
    case inspection

    var id: String { rawValue }
    var title: String {
        switch self {
        case .good:
            "Годное"
        case .inspection:
            "На проверку"
        }
    }
    var iconName: String {
        switch self {
        case .good:
            "checkmark.circle.fill"
        case .inspection:
            "exclamationmark.triangle.fill"
        }
    }
}

extension ReturnDecision {
    var containerSlot: ReturnContainerSlot {
        switch self {
        case .good:
            .good
        case .defect, .wrongItem:
            .inspection
        }
    }
}
