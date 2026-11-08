import SwiftUI

struct ReturnsDecisionButton: View {
    let decision: ReturnDecision
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: decision.iconName)
                    .font(.system(size: 26))
                    .foregroundStyle(decision.color)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(decision.title)
                        .font(.system(size: 18, weight: .semibold))
                    Text(decision.subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(ColorPalette.brandMuted)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(
                    decision.color.opacity(0.12)
                )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(ReturnsDecisionButtonStyle())
        .foregroundStyle(ColorPalette.textPrimary)
    }
}

struct ReturnsDecisionButtonStyle: ButtonStyle {
    var scalesOnPress = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && scalesOnPress ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ReturnDecision {
    var color: Color {
        switch self {
        case .good:
            ColorPalette.success
        case .defect:
            ColorPalette.error
        case .wrongItem:
            ColorPalette.brandMuted
        }
    }
}
