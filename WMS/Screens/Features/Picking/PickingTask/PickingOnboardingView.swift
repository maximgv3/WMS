import SwiftUI

struct PickingOnboardingView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPickingOnboardingComplete") private var isPickingOnboardingComplete = false
    @State private var selectedPage = 0
    private let pages: [PickingOnboardingPage] = [
        .init(
            id: 0,
            image: .goToPlace,
            text: "Пройдите к ячейке, указанной на экране"
        ),
        .init(
            id: 1,
            image: .checkItemId,
            text: "Найдите вещь с соответствующим штрих-кодом"
        ),
        .init(
            id: 2,
            image: .checkIsItemRight,
            text: "Проверьте соответствие характеристик товара"
        ),
        .init(id: 3, image: .scanItem, text: "Отсканируйте штрих-код"),
        .init(
            id: 4,
            image: .collectOtherItems,
            text: "Таким же образом соберите оставшиеся предметы"
        ),
        .init(
            id: 5,
            image: .scanFinishPlace,
            text: "Пройдите к точке сброса вещей, отсканируйте QR места"
        ),
        .init(
            id: 6,
            image: .scanFinishContainer,
            text: "Отсканируйте контейнер"
        ),
        .init(
            id: 7,
            image: .placeItemsInContainer,
            text: "Сложите вещи в контейнер"
        ),
    ]

    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(pages) { page in
                onboardingPage(image: page.image, text: page.text)
                    .tag(page.id)
            }
            completionPage
                .tag(8)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea()
    }

    private var completionPage: some View {
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

    private func onboardingPage(image: ImageResource, text: String) -> some View {
        VStack {
            Spacer()
            onboardingText(text)
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

    @ViewBuilder
    private func onboardingText(_ text: String) -> some View {
        let label = Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(ColorPalette.brandPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        if #available(iOS 26.0, *) {
            label
                .glassEffect()
        } else {
            label
                .background(.thinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
        }
    }
}

private struct PickingOnboardingPage: Identifiable {
    let id: Int
    let image: ImageResource
    let text: String
}

#Preview {
    PickingOnboardingView()
}
