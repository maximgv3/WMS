import SwiftUI

extension Text {
    static func itemId(
        _ id: Int,
        suffixSize: Int = 4,
        base: Font.Weight = .regular,
        tail: Font.Weight = .heavy
    ) -> Text {
        let string = String(id)
        return Text(String(string.dropLast(suffixSize))).fontWeight(base)
            + Text(String(string.suffix(suffixSize))).fontWeight(tail)
    }
}
