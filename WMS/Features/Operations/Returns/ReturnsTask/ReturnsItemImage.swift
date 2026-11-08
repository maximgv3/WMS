import SwiftUI

struct ReturnsItemImage: View {
    let item: Item

    var body: some View {
        if let imageUrl = item.imageUrl {
            AsyncImage(url: imageUrl) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                placeholder
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Image(systemName: "photo")
            .font(.system(size: 22))
            .foregroundStyle(ColorPalette.textPrimary)
    }
}
