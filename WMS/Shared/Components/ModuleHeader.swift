import SwiftUI

struct ModuleHeader: View {
    let title: String
    var onBack: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let onBack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .offset(y: 1.5)
                }
                .buttonStyle(.plain)
            }

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(ColorPalette.brandPrimary)
    }
}

#Preview {
    VStack(spacing: 0) {
        ModuleHeader(title: "Сборка", onBack: {})
        ModuleHeader(title: "Операции")
        Spacer()
    }
    .background(ColorPalette.brandPrimary)
}
