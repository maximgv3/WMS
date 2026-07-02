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
                    .font(font)
                    .foregroundStyle(ColorPalette.brandPrimary)
                    .opacity(isLoading ? 0 : 1)
            }
            .frame(maxWidth: maxWidth)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(ColorPalette.accentPrimary)
            .clipShape(shape)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }

    private var font: Font {
        switch variant {
        case .fullWidth:
            return .system(size: 20, weight: .medium)
        case .capsule:
            return .system(size: 17, weight: .semibold)
        }
    }

    private var maxWidth: CGFloat? {
        switch variant {
        case .fullWidth:
            return .infinity
        case .capsule:
            return nil
        }
    }

    private var horizontalPadding: CGFloat {
        switch variant {
        case .fullWidth:
            return 0
        case .capsule:
            return 20
        }
    }

    private var verticalPadding: CGFloat {
        switch variant {
        case .fullWidth:
            return 14
        case .capsule:
            return 12
        }
    }

    private var shape: PrimaryButtonShape {
        switch variant {
        case .fullWidth:
            return PrimaryButtonShape(cornerRadius: 24)
        case .capsule:
            return PrimaryButtonShape(cornerRadius: 999)
        }
    }
}

private struct PrimaryButtonShape: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .path(in: rect)
    }
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
