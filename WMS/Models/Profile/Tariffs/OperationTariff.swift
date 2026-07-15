import Foundation

struct OperationTariff: Identifiable {
    var id: String { operation + " " + zone }
    let operation: String
    let zone: String
    let rateKopecks: Int
}
