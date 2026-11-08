import SwiftUI

struct ReturnsContainerChip: View {
    let slot: ReturnContainerSlot
    let code: String
    let isRebinding: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: slot.iconName)
                    .foregroundStyle(color)
                VStack(alignment: .leading, spacing: 0) {
                    Text(slot.title)
                        .font(.system(size: 13))
                        .foregroundStyle(ColorPalette.brandMuted)
                    Text(code)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .monospacedDigit()
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(
                    color.opacity(isRebinding ? 0.28 : 0.12)
                )
            )
            .shimmer(isRebinding)
            .glassIfAvailable(
                isRebinding,
                shape: RoundedRectangle(cornerRadius: 14, style: .continuous),
                isDimmed: false
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(ReturnsDecisionButtonStyle(scalesOnPress: !isRebinding))
        .foregroundStyle(ColorPalette.textPrimary)
    }

    private var color: Color {
        switch slot {
        case .good:
            ColorPalette.success
        case .inspection:
            ColorPalette.error
        }
    }
}
