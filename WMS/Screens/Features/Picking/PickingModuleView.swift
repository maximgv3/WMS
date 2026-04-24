import SwiftUI

struct PickingModuleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoadingTask = false

    var body: some View {
        ZStack {
            ColorPalette.brandPrimary

            VStack(spacing: 0) {
                customTopBar
                content
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 28,
                            topTrailingRadius: 28
                        )
                    )
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var content: some View {
        VStack(spacing: 60) {
            Image(.pickingList)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)

            Button {
                getTaskTapped()
            } label: {
                Group {
                    if isLoadingTask {
                        ProgressView()
                            .tint(ColorPalette.brandPrimary)
                    } else {
                        Text("Получить задание")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(ColorPalette.brandPrimary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ColorPalette.accentPrimary)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
            }
            .padding(.horizontal, 64)
            .buttonStyle(.plain)
            .disabled(isLoadingTask)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary)
    }
    private var customTopBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .offset(y: 1.5)
            }
            .buttonStyle(.plain)

            Text("Сборка")
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

    private func getTaskTapped() {
        isLoadingTask = true
    }
}

#Preview {
    PickingModuleView()
}
