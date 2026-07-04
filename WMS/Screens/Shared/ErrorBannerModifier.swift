import SwiftUI

struct ErrorBannerModifier: ViewModifier {
    let title: String
    @Binding var message: String?
    var autoDismissAfter: Duration = .seconds(3)

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message {
                    ErrorBannerView(title: title, message: message)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 16)
                        .transition(.move(edge: .top))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: message)
            .task(id: message) {
                guard message != nil else { return }
                try? await Task.sleep(for: autoDismissAfter)
                guard !Task.isCancelled else { return }
                message = nil
            }
    }
}

extension View {
    func errorBanner(title: String, message: Binding<String?>) -> some View {
        modifier(ErrorBannerModifier(title: title, message: message))
    }
}
