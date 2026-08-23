import SwiftUI

struct ErrorBannerModifier: ViewModifier {
    let title: String
    @Binding var message: String?
    var autoDismissAfter: Duration = .seconds(3)

    @State private var dragOffset: CGFloat = 0

    private let dismissDragDistance: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message {
                    ErrorBannerView(title: title, message: message)
                        .offset(y: dragOffset)
                        .gesture(dismissDragGesture)
                        .padding(16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.bouncy, value: message)
            .task(id: message) {
                guard message != nil else { return }
                dragOffset = .zero
                try? await Task.sleep(for: autoDismissAfter)
                guard !Task.isCancelled else { return }
                message = nil
            }
    }

    private var dismissDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let height = value.translation.height
                // Downwards the banner resists, it has nowhere to go
                dragOffset = height < 0 ? height : height / 4
            }
            .onEnded { value in
                if value.translation.height < -dismissDragDistance {
                    message = nil
                } else {
                    withAnimation(.bouncy) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

extension View {
    func errorBanner(title: String, message: Binding<String?>) -> some View {
        modifier(ErrorBannerModifier(title: title, message: message))
    }
}
