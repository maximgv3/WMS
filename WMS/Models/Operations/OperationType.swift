import Foundation

nonisolated enum OperationType: String, CaseIterable, Identifiable {
    case putaway
    case picking
    case returns

    var id: String { rawValue }
    var title: String {
        switch self {
        case .putaway:
            "Раскладка"
        case .picking:
            "Сборка"
        case .returns:
            "Проверка возвратов"
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
}
