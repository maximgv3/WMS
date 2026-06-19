import Foundation

struct ProfileFinanceSummary {
    let pendingFundsKopecks: Int
    let totalBalanceKopecks: Int
    let incomeLast30Days: Int
    let incomeLastYear: Int
    let transactions: [FinanceTransaction]
}
