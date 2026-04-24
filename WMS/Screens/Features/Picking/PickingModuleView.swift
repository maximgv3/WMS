import SwiftUI

struct PickingModuleView: View {
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "arrow.down.circle")
                .foregroundStyle(ColorPalette.brandPrimary)
                .font(.system(size: 64))
            Button("Получить задание") {
                getTaskTapped()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(ColorPalette.accentPrimary)
            .foregroundStyle(ColorPalette.brandPrimary)
            .font(.system(size: 20, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary)
    }

    private func getTaskTapped() {

    }
}

#Preview {
    PickingModuleView()
}
