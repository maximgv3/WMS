import SwiftUI

struct ErrorBannerView: View {
    let title: String
    let message: String?

    var body: some View {
        VStack(spacing: .zero) {
            Text(title)
                .foregroundStyle(ColorPalette.surfacePrimary)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            if let message {
                Text(message)
                    .padding(.top, 4)
                    .foregroundStyle(ColorPalette.surfacePrimary)
                    .font(.system(size: 16, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(ColorPalette.error)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
