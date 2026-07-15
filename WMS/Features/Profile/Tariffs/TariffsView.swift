import SwiftUI

struct TariffsView: View {
    @State private var viewModel: TariffsViewModel
    init(service: TariffsServiceProtocol) {
        self.viewModel = TariffsViewModel(service: service)
    }

    @State private var showFilters = false

    var body: some View {
        ZStack {
            ColorPalette.brandPrimary.ignoresSafeArea()
            content
        }
        .task {
            await viewModel.loadTariffs()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFilters = true
                } label: {
                    Image(
                        systemName: viewModel.hasActiveFilters
                            ? "line.3.horizontal.decrease.circle.fill"
                            : "line.3.horizontal.decrease.circle"
                    )
                }
                .popover(isPresented: $showFilters) {
                    filterList
                }
            }
        }
    }

    private var filterList: some View {
        List {
            Section("Блок") {
                ForEach(viewModel.allZones, id: \.self) { zone in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleZone(zone)
                        }
                    } label: {
                        HStack {
                            Text(zone)
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.selectedZones.contains(zone) {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(ColorPalette.brandPrimary)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section("Операция") {
                ForEach(viewModel.allOperations, id: \.self) { operation in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleOperation(operation)
                        }
                    } label: {
                        HStack {
                            Text(operation)
                                .foregroundStyle(.primary)
                            Spacer()
                            if viewModel.selectedOperations.contains(operation) {
                                Image(systemName: "checkmark")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(ColorPalette.brandPrimary)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
            if viewModel.hasActiveFilters {
                Section {
                    Button("Сбросить", role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.resetFilters()
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(width: 280, height: 460)
        .padding(.top, 16)
        .presentationCompactAdaptation(.popover)
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
    NavigationStack {
        TariffsView(service: TariffsServiceMock())
    }
}
