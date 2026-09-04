import SwiftUI

struct IconChip: View {
    let systemName: String
    let size: CGFloat
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.5))
            .foregroundStyle(ColorPalette.brandPrimary)
            .frame(width: size, height: size)
            .background(ColorPalette.accentPrimary.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.27, style: .continuous))
    }
}

#Preview {
    IconChip(systemName: "shippingbox", size: 44)
    IconChip(systemName: "shippingbox", size: 36)
}
