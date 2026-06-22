import Foundation

struct FinanceTransaction: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let date: Date
    let amountKopecks: Int
    let category: FinanceTransactionCategory
}

enum FinanceTransactionCategory {
    case pending
    case balance
}
