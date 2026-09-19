import SwiftUI

struct ShimmerModifier: ViewModifier {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSweeping = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        let shimmerWidth = min(max(width * 0.18, 50), 90)
                        
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.22),
                                .white.opacity(0.50),
                                .white.opacity(0.32),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: shimmerWidth, height: proxy.size.height * 2)
                        .rotationEffect(.degrees(15))
                        .offset(x: isSweeping ? width + shimmerWidth : -shimmerWidth, y: -proxy.size.height / 2 )
                    }
                    .mask {
                        content
                    }
                    .animation(
                        .timingCurve(
                            0.4, 0.0,
                            0.2, 1.0,
                            duration: 2.6
                        ).repeatForever(autoreverses: false),
                        value: isSweeping
                    )
                    .onAppear {
                        isSweeping = true
                    }
                }
            }
    }
}

extension View {
    @ViewBuilder
    func shimmer(_ isActive: Bool = true) -> some View {
        if isActive {
            modifier(ShimmerModifier())
        } else {
            self
        }
    }
}

#Preview {
    Text(.operationsContinueTask)
        .font(.caption.weight(.semibold))
        .foregroundStyle(ColorPalette.success)
        .shimmer()
}
