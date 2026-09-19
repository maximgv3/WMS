import SwiftUI

extension View {
    @ViewBuilder
    func glassIfAvailable(
        _ isActive: Bool = true,
        shape: some Shape = Capsule(),
        background: some ShapeStyle = Material.ultraThinMaterial,
        isDimmed: Bool = false
    ) -> some View {
        if isActive {
            if #available(iOS 26, *) {
                self
                    .overlay {
                        if isDimmed {
                            shape
                                .fill(.black.opacity(0.05))
                                .allowsHitTesting(false)
                        }
                    }
                    .glassEffect(.regular.interactive(), in: shape)
            } else {
                self.background(background, in: shape)
            }
        } else {
            self
        }
    }
}
