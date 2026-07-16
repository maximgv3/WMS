import Foundation
import Observation

@Observable
final class ProfileFinanceViewModel {
    private let service: ProfileFinanceServiceProtocol

    var summary: ProfileFinanceSummary?
    var isLoading = false
    var errorMessage: String?

    var transactionSections: [FinanceTransactionSection] = []

    init(service: ProfileFinanceServiceProtocol) {
        self.service = service
    }

    func loadFinances() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let summary = try await service.getFinanceSummary()
            self.summary = summary
            self.transactionSections = makeTransactionSections(from: summary.transactions)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func makeTransactionSections(from transactions: [FinanceTransaction])
        -> [FinanceTransactionSection]
    {
        let calendar = Calendar.current
        return Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
        .map { date, transactions in
            FinanceTransactionSection(
                date: date,
                transactions: sortedTransactions(transactions)
            )
        }
        .sorted { $0.date > $1.date }
    }

    private func sortedTransactions(_ transactions: [FinanceTransaction])
        -> [FinanceTransaction]
    {
        transactions.sorted { lhs, rhs in
            if lhs.category == rhs.category {
                return lhs.date > rhs.date
            }
            return lhs.category == .pending
        }
    }
}
