import SwiftUI

struct ItemInfoTable: View {
    let item: Item

    var body: some View {
        VStack(spacing: 0) {
            infoRow(
                title: "Ячейка",
                value: item.placement ?? "—",
                isPrimary: true
            )
            infoRow(title: "Размер", value: item.size ?? "—")
            infoRow(title: "Цвет", value: item.color ?? "—")
            infoRow(title: "Артикул", value: item.article)
            infoRow(title: "Бренд", value: item.brand ?? "—")
            infoRow(title: "Остаток", value: "\(item.stock) шт.")
        }
        .padding(.horizontal, 16)
    }

    private func infoRow(title: String, value: String, isPrimary: Bool = false)
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
