import Foundation

nonisolated enum ReturnDecision: String, CaseIterable, Identifiable, Sendable, Hashable {
    case good
    case defect
    case wrongItem

    var id: String { rawValue }
    var title: LocalizedStringResource {
        switch self {
        case .good:
            .returnsDecisionSellable
        case .defect:
            .returnsDefective
        case .wrongItem:
            .returnsWrongItem
        }
    }
    var subtitle: LocalizedStringResource {
        switch self {
        case .good:
            .returnsReturnToStock
        case .defect:
            .returnsSendToTheDefectiveItemsArea
        case .wrongItem:
            .returnsADifferentItemWasReturned
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

    var badgeIconName: String {
        switch self {
        case .good:
            "checkmark"
        case .defect:
            "exclamationmark"
        case .wrongItem:
            "questionmark"
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

    var photoHint: LocalizedStringResource {
        switch self {
        case .good:
            .returnsPhotographTheItem
        case .defect:
            .returnsPhotographTheDamage
        case .wrongItem:
            .returnsPhotographTheReturnedItem
        }
    }
}
