import Foundation

nonisolated enum OperationType: String, CaseIterable, Identifiable {
    case picking
    case receiving
    case inventory

    var id: String { rawValue }
    var title: String {
        switch self {
        case .picking:
            "Сборка"
        case .receiving:
            "Приёмка"
        case .inventory:
            "Инвентаризация"
        }
    }
    var iconName: String {
        switch self {
        case .picking:
            "cart"
        case .receiving:
            "shippingbox"
        case .inventory:
            "checklist"
        }
    }
}
