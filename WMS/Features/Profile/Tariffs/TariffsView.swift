import SwiftUI

struct TariffsView: View {
    @State private var viewModel: TariffsViewModel
    init(service: TariffsServiceProtocol) {
        self.viewModel = TariffsViewModel(service: service)
    }

    var body: some View {
        ZStack {
            ColorPalette.brandPrimary.ignoresSafeArea()
            content
        }
        .task {
            await viewModel.loadTariffs()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.tariffs.isEmpty {
            ProgressView()
                .tint(ColorPalette.surfacePrimary)
        } else if let error = viewModel.errorMessage, viewModel.tariffs.isEmpty {
            errorState(error)
        } else if viewModel.tariffs.isEmpty {
            ErrorView(
                type: .other(
                    icon: "shippingbox",
                    title: "Тарифы недоступны.\nПопробуйте позже.",
                    autoDismiss: false
                )
            )
        } else {
            loadedState
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 40) {
            Text(message)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(ColorPalette.surfacePrimary)
                .multilineTextAlignment(.center)
            PrimaryButton("Попробовать снова", variant: .capsule) {
                Task { await viewModel.loadTariffs() }
            }
        }
        .padding(.horizontal, 24)
    }

    private var loadedState: some View {
        VStack(spacing: .zero) {
            Text("Тарифы")
                .font(.largeTitle).bold()
                .foregroundStyle(ColorPalette.surfacePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

            ZStack(alignment: .top) {
                Color.white
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 32,
                            topTrailingRadius: 32
                        )
                    )
                    .ignoresSafeArea(edges: .bottom)
                tariffsList
            }
        }
    }

    private var tariffsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ForEach(viewModel.sections) { section in
                    sectionView(section)
                }
            }
            .padding(.top, 12)
            .padding(20)
        }
        .scrollIndicators(.hidden)
    }

    private func sectionView(_ section: TariffZoneSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.zone)
                .font(.title3).bold()
            VStack(spacing: 0) {
                ForEach(Array(section.tariffs.enumerated()), id: \.element.id) { index, tariff in
                    tariffRow(tariff)
                    if index < section.tariffs.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    private func tariffRow(_ tariff: OperationTariff) -> some View {
        HStack {
            Text(tariff.operation)
                .font(.body)
            Spacer()
            Text(tariff.rateKopecks.formattedAsRubles(fractionDigits: 2))
                .font(.headline)
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    TariffsView(service: TariffsServiceMock())
}
