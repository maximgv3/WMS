import Foundation

extension Date {
    /// Full date and time in the user's locale.
    /// Used for "last updated" style timestamps.
    func formattedAsProfileTimestamp() -> String {
        formatted(
            .dateTime
                .locale(.current)
                .day()
                .month(.wide)
                .year()
                .hour()
                .minute()
        )
    }

    /// Day, wide month and year in the user's locale.
    /// Used for dates that are rarely recent, like document updates.
    func formattedAsDocumentDate() -> String {
        formatted(
            .dateTime
                .locale(.current)
                .day()
                .month(.wide)
                .year()
        )
    }

    /// Day and wide month, with "Сегодня"/"Вчера" for recent dates.
    /// Used as a header when grouping items by day.
    func formattedAsSectionHeader(calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(self) {
            return String(localized: .commonToday)
        }
        if calendar.isDateInYesterday(self) {
            return String(localized: .commonYesterday)
        }
        return formatted(
            .dateTime
                .day()
                .month(.wide)
        )
    }
}
