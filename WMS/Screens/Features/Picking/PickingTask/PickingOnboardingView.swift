import SwiftUI

struct PickingOnboardingView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPickingOnboardingComplete") private var isPickingOnboardingComplete = false
    @State private var selectedPage = 0

    var body: some View {
        TabView(selection: $selectedPage) {
            page(image: .goToPlace, text: "Пройдите к ячейке, указанной на экране")
                .tag(0)
            page(image: .checkItemId, text: "Найдите вещь с соответствующим штрих-кодом")
                .tag(1)
            page(image: .checkIsItemRight, text: "Проверьте соответствие характеристик товара")
                .tag(2)
            page(image: .scanItem, text: "Отсканируйте штрих-код")
                .tag(3)
            page(image: .collectOtherItems, text: "Таким же образом соберите оставшиеся предметы")
                .tag(4)
            page(image: .scanFinishPlace, text: "Пройдите к точке сброса вещей, отсканируйте QR места")
                .tag(5)
            page(image: .scanFinishContainer, text: "Отсканируйте контейнер")
                .tag(6)
            page(image: .placeItemsInContainer, text: "Сложите вещи в контейнер")
                .tag(7)
            finalPage
                .tag(8)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea()
    }

    private var finalPage: some View {
        VStack {
            Spacer()
            Image(.pickingOnboardingEnd)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .padding(48)
            Spacer()
            Button {
                isPickingOnboardingComplete = true
                dismiss()
            } label: {
                Text("Завершить обучение")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(ColorPalette.brandPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(ColorPalette.accentPrimary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                    )
            }
            .padding(.horizontal, 64)
            .padding(.bottom, 16)
            .buttonStyle(.plain)
        }
        .background(ColorPalette.backgroundPrimary)
    }

    private func page(image: ImageResource, text: String) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(ColorPalette.brandPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding(.bottom, 48)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .clipped()
        .ignoresSafeArea()
    }
}

#Preview {
    PickingOnboardingView()
}
