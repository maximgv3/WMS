import Foundation

struct TariffZoneSection: Identifiable {
    let zone: String
    let tariffs: [OperationTariff]

    var id: String { zone }
}
