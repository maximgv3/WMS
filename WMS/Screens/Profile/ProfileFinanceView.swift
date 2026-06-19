import SwiftUI

struct ProfileFinanceView: View {
    @State private var viewModel: ProfileFinanceViewModel
    init(service: ProfileFinanceServiceProtocol) {
        self.viewModel = ProfileFinanceViewModel(service: service)
    }

    @State private var scrollOffset: CGFloat = 0
    private var incomeOpacity: Double {
        let fadeStartOffset: CGFloat = -20
        let fadeEndOffset: CGFloat = -140

        if scrollOffset >= fadeStartOffset { return 1 }
        if scrollOffset <= fadeEndOffset { return 0 }

        return Double((scrollOffset - fadeEndOffset) / (fadeStartOffset - fadeEndOffset))
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
            .opacity(incomeOpacity)
            .offset(y: max(scrollOffset, 0))

            GeometryReader { screenProxy in
                ScrollView {
                    GeometryReader { scrollProxy in
                        Color.clear
                            .onChange(
                                of: scrollProxy.frame(in: .named("financeScroll"))
                                    .minY
                            ) { _, value in
                                scrollOffset = value
                            }
                    }
                    .frame(height: 0)

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
                        .frame(minHeight: screenProxy.size.height - 220)

                        LazyVStack(spacing: 24) {
                            Text("+1 250 ₽ — За задание PICK-1042")
                                .bold()
                            Text("+981 ₽ — За задание PICK-1041")
                                .bold()
                            Text("-320 ₽ — Покупка в столовой")
                                .bold()
                            Text("+1 541 ₽ — За задание PICK-1038")
                                .bold()
                            Text("+2 100 ₽ — За вечернюю смену")
                                .bold()
                            Text("+150 ₽ — Компенсация проезда")
                                .bold()
                            Text("+1 320 ₽ — За задание PICK-1035")
                                .bold()
                            Text("+875 ₽ — За задание PICK-1034")
                                .bold()
                            Text("-180 ₽ — Кофе и перекус")
                                .bold()
                            Text("+1 760 ₽ — За задание PICK-1031")
                                .bold()
                            Text("+2 450 ₽ — Доплата за смену")
                                .bold()
                            Text("+990 ₽ — За задание PICK-1029")
                                .bold()
                            Text("-260 ₽ — Обед в столовой")
                                .bold()
                            Text("+1 430 ₽ — За задание PICK-1027")
                                .bold()
                            Text("+1 080 ₽ — За задание PICK-1026")
                                .bold()
                            Text("+1 900 ₽ — За задание PICK-1024")
                                .bold()
                            Text("-210 ₽ — Покупка в столовой")
                                .bold()
                            Text("+1 115 ₽ — За задание PICK-1022")
                                .bold()
                            Text("+2 300 ₽ — Закрытие срочного задания")
                                .bold()
                            Text("+780 ₽ — За задание PICK-1019")
                                .bold()
                            Text("-95 ₽ — Напиток")
                                .bold()
                            Text("+1 640 ₽ — За задание PICK-1017")
                                .bold()
                            Text("+1 250 ₽ — За задание PICK-1016")
                                .bold()
                            Text("+500 ₽ — Бонус за скорость")
                                .bold()
                            Text("-340 ₽ — Обед в столовой")
                                .bold()
                            Text("+1 470 ₽ — За задание PICK-1014")
                                .bold()
                            Text("+1 050 ₽ — За задание PICK-1013")
                                .bold()
                            Text("+2 000 ₽ — Доплата за переработку")
                                .bold()
                            Text("+920 ₽ — За задание PICK-1011")
                                .bold()
                            Text("-150 ₽ — Кофе")
                                .bold()
                            Spacer(minLength: 32)
                        }
                        .padding(.top, 32)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scrollIndicators(.hidden)
                .refreshable {
                    await viewModel.loadFinances()
                }
                .coordinateSpace(name: "financeScroll")
                .background {
                    VStack {
                        Spacer()
                        ColorPalette.backgroundPrimary
                            .frame(height: 300)
                    }
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
