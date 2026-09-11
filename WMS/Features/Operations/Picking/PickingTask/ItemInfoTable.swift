import SwiftUI

struct ItemInfoTable: View {
    let item: Item

    var body: some View {
        VStack(spacing: 0) {
            infoRow(
                title: .commonBin,
                value: item.placement ?? "—",
                isPrimary: true
            )
            infoRow(title: .pickingSize, value: item.size ?? "—")
            infoRow(title: .pickingColor, value: item.color ?? "—")
            infoRow(title: .pickingSku, value: item.article)
            infoRow(title: .pickingBrand, value: item.brand ?? "—")
            infoRow(
                title: .pickingStock,
                value: String(localized: .commonPiecesCount(item.stock))
            )
        }
        .padding(.horizontal, 16)
    }

    private func infoRow(
        title: LocalizedStringResource,
        value: String,
        isPrimary: Bool = false
    )
        -> some View
    {
        HStack {
            Text(title)
                .font(
                    .system(
                        size: isPrimary ? 21 : 19,
                        weight: isPrimary ? .semibold : .regular
                    )
                )
                .foregroundStyle(isPrimary ? .primary : .secondary)
            Spacer()
            Text(value)
                .font(
                    .system(
                        size: isPrimary ? 22 : 19,
                        weight: isPrimary ? .bold : .medium
                    )
                )
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, isPrimary ? 14 : 12)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}
