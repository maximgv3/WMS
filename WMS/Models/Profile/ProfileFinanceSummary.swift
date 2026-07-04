import Foundation

struct ProfileFinanceSummary {
    let incomeLast30Days: Int
    let incomeLastYear: Int
    let transactions: [FinanceTransaction]
}
