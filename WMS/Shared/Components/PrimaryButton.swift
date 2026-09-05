import SwiftUI

struct PrimaryButton: View {
    enum Variant {
        case fullWidth
        case capsule
    }

    private let title: String
    private let background: Color
    private let foreground: Color
    private let isLoading: Bool
    private let isDisabled: Bool
    private let isGlassy: Bool
    private let variant: Variant
    private let action: () -> Void
    init(
        _ title: String,
        background: Color = ColorPalette.accentPrimary,
        foreground: Color = ColorPalette.brandPrimary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isGlassy: Bool = false,
        variant: Variant = .fullWidth,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.background = background
        self.foreground = foreground
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.isGlassy = isGlassy
        self.variant = variant
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            styledLabel
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    private var label: some View {
        ZStack {
            ProgressView()
                .tint(foreground)
                .opacity(isLoading ? 1 : 0)

            Text(title)
                .font(style.font)
                .foregroundStyle(foreground)
                .opacity(isLoading ? 0 : 1)
        }
        .frame(maxWidth: style.maxWidth)
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
    }

    @ViewBuilder
    private var styledLabel: some View {
        if isGlassy {
            if #available(iOS 26, *) {
                label.glassEffect(
                    .regular.tint(background).interactive(),
                    in: shape
                )
            } else {
                filledLabel
            }
        } else {
            filledLabel
        }
    }

    private var filledLabel: some View {
        label
            .background(background)
            .clipShape(shape)
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

        PrimaryButton(
            "Закончить задание",
            background: ColorPalette.success,
            foreground: ColorPalette.textInverted,
            isGlassy: true
        ) {}
        .padding(.horizontal, 64)

        PrimaryButton("Попробовать снова", variant: .capsule) {}

        PrimaryButton("Попробовать снова", isLoading: true, variant: .capsule) {}
    }
    .padding()
    .background(ColorPalette.backgroundPrimary)
}
