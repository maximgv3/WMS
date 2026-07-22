import Foundation

nonisolated struct OperationTariff: Identifiable, Sendable {
    var id: String { operation + " " + zone }
    let operation: String
    let zone: String
    let rateKopecks: Int
}
