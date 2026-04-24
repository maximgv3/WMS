import SwiftUI

enum ColorPalette {
    enum Citrus {
        static let accentPrimary = Color(.citrusAccentPrimary)
        static let backgroundPrimary = Color(.citrusBackgroundPrimary)
        static let brandMuted = Color(.citrusBrandMuted)
        static let brandPrimary = Color(.citrusBrandPrimary)
        static let brandSecondary = Color(.citrusBrandSecondary)
        static let error = Color(.citrusError)
        static let success = Color(.citrusSuccess)
        static let surfacePrimary = Color(.citrusSurfacePrimary)
    }

    static var accentPrimary: Color { Citrus.accentPrimary }
    static var backgroundPrimary: Color { Citrus.backgroundPrimary }
    static var brandMuted: Color { Citrus.brandMuted }
    static var brandPrimary: Color { Citrus.brandPrimary }
    static var brandSecondary: Color { Citrus.brandSecondary }
    static var error: Color { Citrus.error }
    static var success: Color { Citrus.success }
    static var surfacePrimary: Color { Citrus.surfacePrimary }

}


#Preview("Citrus Palette") {
    let items: [(String, Color)] = [
        ("BrandPrimary", ColorPalette.Citrus.brandPrimary),
        ("BrandSecondary", ColorPalette.Citrus.brandSecondary),
        ("AccentPrimary", ColorPalette.Citrus.accentPrimary),
        ("BackgroundPrimary", ColorPalette.Citrus.backgroundPrimary),
        ("SurfacePrimary", ColorPalette.Citrus.surfacePrimary),
        ("BrandMuted", ColorPalette.Citrus.brandMuted),
        ("Success", ColorPalette.Citrus.success),
        ("Error", ColorPalette.Citrus.error)
    ]

    VStack(alignment: .leading, spacing: 16) {
        Text("Citrus Palette")
            .font(.headline)

        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(72), spacing: 12), count: 4),
            alignment: .leading,
            spacing: 16
        ) {
            ForEach(items, id: \.0) { item in
                colorTile(name: item.0, color: item.1)
            }
        }
    }
    .padding(16)
    .frame(width: 360, alignment: .topLeading)
    .background(Color(.systemBackground))
    Spacer()
}

private func colorTile(name: String, color: Color) -> some View {
    VStack(spacing: 6) {
        RoundedRectangle(cornerRadius: 14)
            .fill(color)
            .frame(width: 72, height: 72)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )

        Text(name)
            .font(.caption2)
            .foregroundStyle(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .frame(width: 72, height: 32, alignment: .top)
    }
    .frame(width: 72, height: 110, alignment: .top)
}
