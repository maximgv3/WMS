import SwiftUI

struct PrimaryButton: View {
    enum Variant {
        case fullWidth
        case capsule
    }

    private let title: String
    private let isLoading: Bool
    private let isDisabled: Bool
    private let variant: Variant
    private let action: () -> Void

    init(
        _ title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        variant: Variant = .fullWidth,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.variant = variant
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                ProgressView()
                    .tint(ColorPalette.brandPrimary)
                    .opacity(isLoading ? 1 : 0)

                Text(title)
                    .font(style.font)
                    .foregroundStyle(ColorPalette.brandPrimary)
                    .opacity(isLoading ? 0 : 1)
            }
            .frame(maxWidth: style.maxWidth)
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .background(ColorPalette.accentPrimary)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    private var style: Style {
        switch variant {
        case .fullWidth:
            Style(
                font: .system(size: 20, weight: .medium),
                maxWidth: .infinity,
                horizontalPadding: 0,
                verticalPadding: 14,
                cornerRadius: 24
            )
        case .capsule:
            Style(
                font: .system(size: 17, weight: .semibold),
                maxWidth: nil,
                horizontalPadding: 20,
                verticalPadding: 12,
                cornerRadius: 999
            )
        }
    }
}

private struct Style {
    let font: Font
    let maxWidth: CGFloat?
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let cornerRadius: CGFloat
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Получить задание") {}
            .padding(.horizontal, 64)

        PrimaryButton("Завершить задание", isLoading: true) {}
            .padding(.horizontal, 64)

        PrimaryButton("Попробовать снова", variant: .capsule) {}

        PrimaryButton("Попробовать снова", isLoading: true, variant: .capsule) {}
    }
    .padding()
    .background(ColorPalette.backgroundPrimary)
}
