import SwiftUI

struct ReturnsItemCard: View {
    let returnItem: ReturnItem?

    var body: some View {
        ZStack {
            if let returnItem {
                itemCard(returnItem)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                emptyCard
                    .transition(.opacity)
            }
        }
    }

    private var emptyCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 40, weight: .light))
            Text(.returnsItemNotScanned)
                .font(.system(size: 20, weight: .medium))
        }
        .foregroundStyle(ColorPalette.textPrimary)
        .frame(maxWidth: .infinity, minHeight: 140)
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    ColorPalette.textPrimary,
                    style: StrokeStyle(lineWidth: 2, dash: [6])
                )
        }
    }

    private func itemCard(_ returnItem: ReturnItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ReturnsItemImage(item: returnItem.item)
                    .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 6) {
                    Text(returnItem.displayTitle)
                        .font(.system(size: 20, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text.itemId(returnItem.id)
                        .monospacedDigit()
                }
                Spacer()
            }

            HStack(spacing: 6) {
                Image(systemName: "arrow.uturn.backward")
                Text(.returnsReason(returnItem.reason))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .padding(16)
        .foregroundStyle(ColorPalette.textPrimary)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                ColorPalette.surfaceAccent
            )
        )
    }
}
