import Foundation

protocol ProfileFinanceServiceProtocol: AnyObject {
    func getFinanceSummary() async throws -> ProfileFinanceSummary
}

final class ProfileFinanceServiceMock: ProfileFinanceServiceProtocol {
    func getFinanceSummary() async throws -> ProfileFinanceSummary {
        try await Task.sleep(for: .seconds(0.3))
        return ProfileFinanceSummary(
            pendingFundsKopecks: 814_941,
            totalBalanceKopecks: 1_000_000,
            incomeLast30Days: 39_666_06,
            incomeLastYear: 212_341_17,
            transactions: [
                FinanceTransaction(
                    id: UUID(),
                    title: "За задание PICK-1042",
                    date: daysAgo(1),
                    amount: 1_250.00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "За задание PICK-1041",
                    date: daysAgo(1),
                    amount: 980.50,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Покупка в столовой",
                    date: daysAgo(2),
                    amount: -320.00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "За задание PICK-1038",
                    date: daysAgo(3),
                    amount: 1_540.75,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "За вечернюю смену",
                    date: daysAgo(4),
                    amount: 2_100.00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Компенсация проезда",
                    date: daysAgo(5),
                    amount: 150.00,
                    category: .pending
                )
            ]
        )
    }

    private func daysAgo(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -value, to: .now) ?? .now
    }
}
