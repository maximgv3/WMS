import SwiftUI

struct ScannerView: View {
    @Binding var isScanningEnabled: Bool
    let idleText: String
    let activeText: String
    var previewHeight: CGFloat = 130
    let onScan: (String) -> Void

    var body: some View {
        ScannerPreviewView(
            scanAreaSize: nil,
            isScanningEnabled: isScanningEnabled,
            onScan: onScan
        )
        .frame(maxWidth: .infinity)
        .frame(maxHeight: previewHeight)
        .layoutPriority(1)
        .clipShape(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    isScanningEnabled
                        ? ColorPalette.accentPrimary
                        : ColorPalette.brandMuted.opacity(0.35),
                    lineWidth: isScanningEnabled ? 3 : 1
                )
        }
        .overlay {
            HStack(spacing: 10) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 24)
                    .padding(.leading, 10)

                Text(isScanningEnabled ? activeText : idleText)
                    .font(.system(size: 18, weight: .bold))
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 10)
            .foregroundStyle(ColorPalette.surfacePrimary)
            .opacity(isScanningEnabled ? 0.35 : 0.85)
        }
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) { } onPressingChanged: { isPressing in
            isScanningEnabled = isPressing
        }
    }
}
