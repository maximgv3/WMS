import SwiftUI

struct MenuRow: View {
    let title: String
    let icon: String
    var value: String?
    var showsChevron = true

    var body: some View {
        HStack(spacing: 16) {
            IconChip(systemName: icon, size: 36)

            Text(title)
                .foregroundStyle(ColorPalette.brandPrimary)

            Spacer()

            if let value {
                Text(value)
                    .foregroundStyle(ColorPalette.brandMuted)
            }

            if showsChevron {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray.opacity(0.5))
            }
        }
        .padding(8)
        .frame(height: 56)
        .background(ColorPalette.surfacePrimary)
    }
}

#Preview() {
    MenuRow(title: "Menu Test", icon: "star", value: "25", showsChevron: true)
}
