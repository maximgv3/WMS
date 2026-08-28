import Foundation

nonisolated enum ReturnDecision: String, CaseIterable, Identifiable, Sendable, Hashable {
    case good
    case defect
    case wrongItem

    var id: String { rawValue }
    var title: String {
        switch self {
        case .good:
            "Годен"
        case .defect:
            "Брак"
        case .wrongItem:
            "Подмена"
        }
    }
    var subtitle: String {
        switch self {
        case .good:
            "Вернуть в продажу"
        case .defect:
            "Отправить в зону брака"
        case .wrongItem:
            "Вернулся не тот товар"
        }
    }
    var iconName: String {
        switch self {
        case .good:
            "checkmark.circle.fill"
        case .defect:
            "exclamationmark.triangle.fill"
        case .wrongItem:
            "questionmark.circle.fill"
        }
    }
    
    var requiresPhoto: Bool {
        switch self {
        case .good:
            false
        case .defect, .wrongItem:
            true
        }
    }
}
