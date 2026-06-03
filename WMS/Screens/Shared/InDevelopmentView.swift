import SwiftUI

/// Temporary placeholder: closes itself after showing that the section is unavailable.
struct InDevelopmentView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                ColorPalette.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 24, weight: .semibold))
                    Text("Раздел в разработке")
                        .font(.system(size: 22, weight: .semibold))
                }
                .foregroundStyle(ColorPalette.brandPrimary)
            }
            .onAppear {
                Task {
                    try await Task.sleep(for: .seconds(2))
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    InDevelopmentView()
}
