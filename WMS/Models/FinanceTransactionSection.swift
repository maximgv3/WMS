import Foundation

struct FinanceTransactionSection: Identifiable, Hashable, Sendable, Decodable {
    let date: Date
    let transactions: [FinanceTransaction]

    var id: Date { date }
}
