import SwiftUI

/// Temporary placeholder: closes itself after showing that the section is unavailable.
struct SimpleBlockerView: View {
    @Environment(\.dismiss) private var dismiss
    let type: SimpleBlockerType
    private var iconName: String {
        if type == .noAccess {
            return "lock"
        } else {
            return "clock"
        }
    }
    private var text: String {
        if type == .noAccess {
            return
                "Доступ к операции ограничен.\n\nОбратитесь к руководителю для получения разрешения."
        } else {
            return "Раздел в разработке"
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
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(2))
                dismiss()
            }
        }
    }
}

enum SimpleBlockerType {
    case noAccess
    case inDevelopment
}

#Preview {
    SimpleBlockerView(type: .inDevelopment)
}
#Preview {
    SimpleBlockerView(type: .noAccess)
}
