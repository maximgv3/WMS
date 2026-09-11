import SwiftUI

struct ErrorBannerView: View {
    let title: LocalizedStringResource
    let message: String?

    private let shape = RoundedRectangle(cornerRadius: 20)

    var body: some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.tint(ColorPalette.error), in: shape)
        } else {
            content
                .background(ColorPalette.error)
                .clipShape(shape)
        }
    }

    private var content: some View {
        VStack(spacing: .zero) {
            Text(title)
                .foregroundStyle(ColorPalette.textInverted)
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            if let message {
                Text(message)
                    .padding(.top, 4)
                    .foregroundStyle(ColorPalette.textInverted)
                    .font(.system(size: 16, weight: .regular))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 16) {
        ErrorBannerView(
            title: .operationsPickingListFetchFailed,
            message: "Check your connection and try again"
        )

        ErrorBannerView(title: .commonSomethingWentWrong, message: nil)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ColorPalette.backgroundPrimary)
}
