import SwiftUI

struct ProfileFinanceView: View {
    @State private var viewModel: ProfileFinanceViewModel
    init(service: ProfileFinanceServiceProtocol) {
        self.viewModel = ProfileFinanceViewModel(service: service)
    }

    var body: some View {
        ZStack {
            loadedState
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .task {
            await viewModel.loadFinances()
        }
    }

    private var loadedState: some View {
        ZStack(alignment: .top) {
            ColorPalette.brandPrimary
                .frame(maxHeight: .infinity)
            HStack(spacing: 16) {
                fundsCard(title: "За 30 дней", funds: 65_000_00)
                    .frame(maxWidth: .infinity)
                fundsCard(title: "За год", funds: 450_000_00)
                    .frame(maxWidth: .infinity)
            }
                .padding(.top, 120)
                .padding(.horizontal, 24)

            GeometryReader { proxy in
                ScrollView {
                    Color.clear
                        .frame(height: 220)

                    ZStack(alignment: .top) {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 32,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 32
                        )
                        .fill(ColorPalette.backgroundPrimary)
                        .frame(minHeight: proxy.size.height - 200)

                        LazyVStack(spacing: 24) {
                            Text("Operations History")
                        }
                        .padding(.top, 32)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    VStack {
                        Spacer()
                        ColorPalette.backgroundPrimary
                            .frame(height: 300)
                    }
                }
                .refreshable {
                    await viewModel.loadFinances()
                }
            }
        }
    }

    private func formattedRubles(_ kopecks: Int) -> String {
        let rubles = Decimal(kopecks) / 100

        return rubles.formatted(
            .currency(code: "RUB")
                .locale(Locale(identifier: "ru_RU"))
                .precision(.fractionLength(0))
        )
    }

    private func fundsCard(title: String, funds: Int) -> some View {


        return VStack(spacing: 8) {
            Group {
                Text(formattedRubles(funds))
                    .bold()
                Text(title)
                    .font(.system(size: 16))
            }
            .foregroundStyle(ColorPalette.brandPrimary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(ColorPalette.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var loadingState: some View {
        ProgressView()
    }
    private var errorState: some View {
        Text("Error")
    }
}

#Preview {
    ProfileFinanceView(
        service: ProfileFinanceServiceMock()
    )
}
