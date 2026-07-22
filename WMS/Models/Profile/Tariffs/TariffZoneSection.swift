import Foundation

nonisolated struct TariffZoneSection: Identifiable, Sendable {
    let zone: String
    let tariffs: [OperationTariff]

    var id: String { zone }
}
