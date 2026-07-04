import SwiftUI

struct ItemImage: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .empty:
                        ProgressView()
                            .tint(ColorPalette.brandSecondary)
                            .controlSize(.large)
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
                .id(url)
            } else {
                placeholder
            }
        }
        .frame(height: 240)
        .frame(maxWidth: .infinity)
    }

    private var placeholder: some View {
        Image(systemName: "photo.badge.exclamationmark")
            .font(.system(size: 44))
            .foregroundStyle(ColorPalette.brandMuted)
    }
}
