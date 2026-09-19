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
                        
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.7), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: width / 2)
                        .offset(x: isSweeping ? width * 2.5 : -width / 2 )
                    }
                    .mask {
                        content
                    }
                    .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: isSweeping)
                    .onAppear {
                        isSweeping = true
                    }
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview {
    Text(.operationsContinueTask)
        .font(.caption.weight(.semibold))
        .foregroundStyle(ColorPalette.success)
        .shimmer()
}
