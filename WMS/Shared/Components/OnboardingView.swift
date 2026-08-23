import SwiftUI

struct OnboardingView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPage = 0

    private let pages: [OnboardingPage]
    private let completionImage: ImageResource
    private let onFinish: () -> Void

    init(
        pages: [OnboardingPage],
        completionImage: ImageResource,
        onFinish: @escaping () -> Void
    ) {
        self.pages = pages
        self.completionImage = completionImage
        self.onFinish = onFinish
    }

    var body: some View {
        TabView(selection: $selectedPage) {
            ForEach(pages.indices, id: \.self) { index in
                onboardingPage(
                    image: pages[index].image,
                    text: pages[index].text
                )
                .tag(index)
            }
            completionPage
                .tag(pages.count)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea()
    }

    private var completionPage: some View {
        VStack {
            Spacer()
            Image(completionImage)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .padding(48)
            Spacer()
            PrimaryButton("Завершить обучение") {
                onFinish()
                dismiss()
            }
            .padding(.horizontal, 64)
            .padding(.bottom, 16)
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

    private func onboardingText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(ColorPalette.brandPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassIfAvailable(background: Material.thinMaterial)
    }
}

struct OnboardingPage {
    let image: ImageResource
    let text: String
}

#Preview("Сборка") {
    OnboardingView(
        pages: OnboardingPages.Picking.pages,
        completionImage: .pickingOnboardingEnd
    ) {}
}

#Preview("Раскладка") {
    OnboardingView(
        pages: OnboardingPages.Putaway.pages,
        completionImage: .putawayOnboardingEnd
    ) {}
}
