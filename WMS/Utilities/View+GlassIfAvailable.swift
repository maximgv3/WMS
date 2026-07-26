import SwiftUI

extension View {
    @ViewBuilder
    func glassIfAvailable(
        shape: some Shape = Capsule(),
        background: some ShapeStyle = Material.ultraThinMaterial
    ) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular.interactive(), in: shape)
        } else {
            self.background(background, in: shape)
        }
    }
}
