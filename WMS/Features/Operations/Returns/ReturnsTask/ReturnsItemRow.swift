import SwiftUI

struct ReturnsItemRow: View {
    let returnItem: ReturnItem
    let decision: ReturnDecision?
    let photo: Image?

    var body: some View {
        HStack(spacing: 12) {
            ReturnsItemImage(item: returnItem.item)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(returnItem.displayTitle)
                    .lineLimit(1)
                Text(returnItem.reason)
                    .font(.system(size: 14))
                    .foregroundStyle(ColorPalette.brandMuted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text.itemId(returnItem.id)
                .lineLimit(1)
                .layoutPriority(1)
                .monospacedDigit()

            if let decision {
                decisionMark(decision)
            }
        }
    }

    @ViewBuilder
    private func decisionMark(_ decision: ReturnDecision) -> some View {
        if let photo {
            photo
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: decision.badgeIconName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ColorPalette.textInverted)
                        .frame(width: 16, height: 16)
                        .background(decision.color, in: Circle())
                        .offset(x: 4, y: 4)
                }
        } else {
            Image(systemName: decision.iconName)
                .font(.system(size: 18))
                .foregroundStyle(decision.color)
                .frame(width: 32, height: 32)
        }
    }
}
