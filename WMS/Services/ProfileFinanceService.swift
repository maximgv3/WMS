import Foundation

protocol ProfileFinanceServiceProtocol: AnyObject {
    func getFinanceSummary() async throws -> ProfileFinanceSummary
}

final class ProfileFinanceServiceMock: ProfileFinanceServiceProtocol {
    func getFinanceSummary() async throws -> ProfileFinanceSummary {
        try await Task.sleep(for: .seconds(3.3))
        return ProfileFinanceSummary(
            incomeLast30Days: 39_666_06,
            incomeLastYear: 212_341_17,
            transactions: [
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания сборки PICK-1045",
                    date: daysAgo(0),
                    amountKopecks: 1_360_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания приемки REC-2041",
                    date: daysAgo(0),
                    amountKopecks: 1_180_50,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Покупка в столовой",
                    date: daysAgo(0),
                    amountKopecks: -290_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Вывод зарплаты на карту",
                    date: daysAgo(0),
                    amountKopecks: 8_000_00,
                    category: .balance
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания сборки PICK-1042",
                    date: daysAgo(1),
                    amountKopecks: 1_250_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания сборки PICK-1041",
                    date: daysAgo(1),
                    amountKopecks: 980_50,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Покупка в столовой",
                    date: daysAgo(2),
                    amountKopecks: -320_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания приемки REC-2038",
                    date: daysAgo(3),
                    amountKopecks: 1_540_75,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Вывод зарплаты на карту",
                    date: daysAgo(3),
                    amountKopecks: 12_500_00,
                    category: .balance
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания сборки PICK-1037",
                    date: daysAgo(3),
                    amountKopecks: 1_120_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата вечерней смены",
                    date: daysAgo(4),
                    amountKopecks: 2_100_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Компенсация проезда",
                    date: daysAgo(5),
                    amountKopecks: 150_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания инвентаризации INV-3014",
                    date: daysAgo(5),
                    amountKopecks: 1_860_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания раскладки PUT-4509",
                    date: daysAgo(6),
                    amountKopecks: 1_340_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Покупка в столовой",
                    date: daysAgo(6),
                    amountKopecks: -280_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания сборки PICK-1031",
                    date: daysAgo(7),
                    amountKopecks: 1_760_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания приемки REC-2031",
                    date: daysAgo(7),
                    amountKopecks: 1_430_50,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания раскладки PUT-4502",
                    date: daysAgo(8),
                    amountKopecks: 1_090_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Вывод зарплаты на карту",
                    date: daysAgo(8),
                    amountKopecks: 6_500_00,
                    category: .balance
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания сборки PICK-1028",
                    date: daysAgo(8),
                    amountKopecks: 920_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Кофе и перекус",
                    date: daysAgo(8),
                    amountKopecks: -210_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания инвентаризации INV-3008",
                    date: daysAgo(10),
                    amountKopecks: 2_250_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания сборки PICK-1024",
                    date: daysAgo(10),
                    amountKopecks: 1_110_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания приемки REC-2025",
                    date: daysAgo(12),
                    amountKopecks: 1_680_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Покупка в столовой",
                    date: daysAgo(12),
                    amountKopecks: -350_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Оплата задания сборки PICK-1019",
                    date: daysAgo(14),
                    amountKopecks: 1_470_00,
                    category: .pending
                ),
                FinanceTransaction(
                    id: UUID(),
                    title: "Компенсация проезда",
                    date: daysAgo(14),
                    amountKopecks: 150_00,
                    category: .pending
                )
            ]
        )
    }

    private func daysAgo(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -value, to: .now) ?? .now
    }
}
