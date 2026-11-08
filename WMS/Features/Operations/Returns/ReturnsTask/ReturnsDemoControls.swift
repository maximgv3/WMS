#if DEBUG
    import SwiftUI

    struct ReturnsDemoControls: View {
        let isRebindingSlot: Bool
        let itemCode: String?
        let onScan: (String) -> Void

        private let wrongCode = "0000000000"
        private let containerCode = "WMSCT770999"

        var body: some View {
            HStack(spacing: 12) {
                Button {
                    onScan(wrongCode)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(ColorPalette.error)
                        .frame(width: 56, height: 56)
                        .background(ColorPalette.error.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                if isRebindingSlot {
                    scanButton(.returnsTote, code: containerCode)
                } else if let itemCode {
                    scanButton(.returnsItem, code: itemCode)
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        ColorPalette.brandMuted.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1, dash: [6])
                    )
            }
        }

        private func scanButton(
            _ title: LocalizedStringResource,
            code: String
        ) -> some View {
            Button {
                onScan(code)
            } label: {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(ColorPalette.textInverted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ColorPalette.brandPrimary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
        }
    }
#endif
