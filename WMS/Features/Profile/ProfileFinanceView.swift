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

        return Double(
            (scrollOffset - fadeEndOffset) / (fadeStartOffset - fadeEndOffset)
        )
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
                fundsCard(
                    title: "За 30 дней",
                    funds: viewModel.summary?.incomeLast30Days
                )
                .frame(maxWidth: .infinity)
                fundsCard(
                    title: "За год",
                    funds: viewModel.summary?.incomeLastYear
                )
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
                                of: scrollProxy.frame(
                                    in: .named("financeScroll")
                                )
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

                        if let error = viewModel.errorMessage,
                            viewModel.transactionSections.isEmpty
                        {
                            VStack(spacing: 40) {
                                Text(error)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(ColorPalette.brandPrimary)
                                    .multilineTextAlignment(.center)
                                PrimaryButton(
                                    "Попробовать снова",
                                    variant: .capsule
                                ) {
                                    Task {
                                        await viewModel.loadFinances()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 160)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                        } else if viewModel.isLoading
                            && viewModel.transactionSections.isEmpty
                        {
                            ProgressView()
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .center
                                )
                        } else if viewModel.transactionSections.isEmpty
                            && !viewModel.isLoading
                        {
                            Text("Транзакций нет")
                                .padding(16)
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .center
                                )
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(ColorPalette.brandPrimary)
                        } else {
                            LazyVStack(alignment: .leading, spacing: 24) {
                                ForEach(viewModel.transactionSections) {
                                    section in
                                    transactionSection(
                                        date: section.date,
                                        transactions: section.transactions
                                    )
                                }
                                Spacer(minLength: 32)
                            }
                            .padding(.top, 32)
                            .padding(.horizontal, 24)
                        }
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

    private func transactionSection(
        date: Date,
        transactions: [FinanceTransaction]
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(formattedSectionDate(date))
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(ColorPalette.brandPrimary)
            VStack(alignment: .leading, spacing: 20) {
                ForEach(transactions) { transaction in
                    transactionRow(transaction)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formattedSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Сегодня"
        }
        if calendar.isDateInYesterday(date) {
            return "Вчера"
        }
        return date.formatted(
            .dateTime
                .day()
                .month(.wide)
        )
    }

    private func transactionRow(_ transaction: FinanceTransaction) -> some View
    {
        let isPending = transaction.category == .pending
        let isAmountPositive = transaction.amountKopecks >= 0
        let amountPrefix = isPending && isAmountPositive ? "+" : ""
        let amount =
            amountPrefix
            + formattedRubles(transaction.amountKopecks, symbolsCount: 2)
        let amountColor =
            isPending
            ? (isAmountPositive ? ColorPalette.success : ColorPalette.error)
            : ColorPalette.brandPrimary
        let titleColor =
            isPending ? ColorPalette.brandMuted : ColorPalette.brandSecondary

        return VStack(alignment: .leading, spacing: 4) {
            Text(amount)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(amountColor)
            Text(transaction.title)
                .font(.system(size: 16))
                .foregroundStyle(titleColor)
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formattedRubles(_ kopecks: Int, symbolsCount: Int = 0)
        -> String
    {
        let rubles = Decimal(kopecks) / 100

        return rubles.formatted(
            .currency(code: "RUB")
                .locale(Locale(identifier: "ru_RU"))
                .precision(.fractionLength(symbolsCount))
        )
    }

    private func fundsCard(title: String, funds: Int?) -> some View {
        VStack(spacing: 6) {
            Group {
                if viewModel.isLoading && viewModel.summary == nil {
                    ProgressView()
                } else if let funds {
                    Text(formattedRubles(funds))
                        .font(.system(size: 20))
                        .bold()
                } else {
                    Text("—")
                        .font(.system(size: 20))
                        .bold()
                }
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
}

#Preview {
    ProfileFinanceView(
        service: ProfileFinanceServiceMock()
    )
}
