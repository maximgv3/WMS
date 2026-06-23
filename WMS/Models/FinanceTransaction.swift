import Foundation

struct FinanceTransaction: Identifiable, Hashable, Sendable, Decodable {
    let id: UUID
    let title: String
    let date: Date
    let amountKopecks: Int
    let category: FinanceTransactionCategory
}

enum FinanceTransactionCategory: Decodable {
    case pending
    case balance
}
