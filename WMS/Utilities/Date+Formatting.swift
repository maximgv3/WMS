import Foundation

extension Date {
    /// Full date and time in Russian locale, e.g. "5 июля 2026 г., 14:30".
    /// Used for "last updated" style timestamps.
    func formattedAsProfileTimestamp() -> String {
        formatted(
            .dateTime
                .locale(Locale(identifier: "ru_RU"))
                .day()
                .month(.wide)
                .year()
                .hour()
                .minute()
        )
    }

    /// Day, wide month and year, e.g. "12 июля 2026 г.".
    /// Used for dates that are rarely recent, like document updates.
    func formattedAsDocumentDate() -> String {
        formatted(
            .dateTime
                .locale(Locale(identifier: "ru_RU"))
                .day()
                .month(.wide)
                .year()
        )
    }

    /// Day and wide month, with "Сегодня"/"Вчера" for recent dates.
    /// Used as a header when grouping items by day.
    func formattedAsSectionHeader(calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(self) {
            return "Сегодня"
        }
        if calendar.isDateInYesterday(self) {
            return "Вчера"
        }
        return formatted(
            .dateTime
                .day()
                .month(.wide)
        )
    }
}
