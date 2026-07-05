import Foundation

extension Int {
    func formattedAsRubles(fractionDigits: Int = 0) -> String {
        (Decimal(self) / 100).formatted(
            .currency(code: "RUB")
                .locale(Locale(identifier: "ru_RU"))
                .precision(.fractionLength(fractionDigits))
        )
    }
}
