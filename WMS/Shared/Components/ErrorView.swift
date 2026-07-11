import SwiftUI

struct ErrorView: View {
    @Environment(\.dismiss) private var dismiss
    let type: ErrorViewType
    private var iconName: String {
        switch type {
        case .inDevelopment:
            return "clock"
        case .noAccess:
            return "lock"
        case .other(let icon, _, _):
            return icon
        }
    }

    private var text: String {
        switch type {
        case .inDevelopment:
            return "Раздел в разработке"
        case .noAccess:
            return
                "Доступ к операции ограничен.\n\nОбратитесь к руководителю для получения разрешения."
        case .other(_, let title, _):
            return title
        }
    }

    var body: some View {

        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .semibold))
                Text(text)
                    .font(.system(size: 22, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(ColorPalette.brandPrimary)
        }
        .task {
            if case .other(_, _, let autoDismiss) = type,
                !autoDismiss
            { return }
            do {
                try await Task.sleep(for: .seconds(2))
            } catch { return }
            
            dismiss()
        }
    }
}

enum ErrorViewType {
    case noAccess
    case inDevelopment
    case other(icon: String, title: String, autoDismiss: Bool)
}

#Preview {
    ErrorView(type: .inDevelopment)
}
#Preview {
    ErrorView(type: .noAccess)
}
#Preview {
    ErrorView(type: .other(icon: "shippingbox", title: "Error", autoDismiss: false))
}
