import Charts
import SwiftUI

struct ProfileRatingView: View {
    @State private var viewModel: ProfileRatingViewModel
    init(service: ProfileRatingServiceProtocol) {
        self.viewModel = ProfileRatingViewModel(service: service)
    }

    @State private var selectedDate: Date?
    @State private var showAboutRating = false

    private var selectedPoint: RatingPoint? {
        guard let selectedDate else { return nil }
        return viewModel.nearestPoint(to: selectedDate)
    }

    var body: some View {
        ZStack {
            ColorPalette.brandPrimary.ignoresSafeArea()
            content
        }
        .task {
            await viewModel.loadRating()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.summary == nil {
            ProgressView()
                .tint(ColorPalette.surfacePrimary)
        } else if let error = viewModel.errorMessage, viewModel.history.isEmpty {
            errorState(error)
        } else if viewModel.history.isEmpty {
            ErrorView(type: .other(icon: "chart.xyaxis.line", title: "Недостаточно данных о рейтинге.\nПроверьте спустя несколько дней.", autoDismiss: false))
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
                Task { await viewModel.loadRating() }
            }
        }
        .padding(.horizontal, 24)
    }

    private var loadedState: some View {
        VStack {
            chart
                .frame(height: 200)
                .padding()
            ZStack(alignment: .top) {
                Color.white
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 32,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 32
                        )
                    )
                    .ignoresSafeArea(edges: .bottom)
                operationsGrid
            }
        }
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var operationsGrid: some View {

        ScrollView {
            VStack(spacing: 40) {
                Text("Рейтинг по операциям")
                    .font(.title3).bold()
                LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                    ForEach(viewModel.operations) { operation in
                        OperationRatingCell(operation: operation)
                    }
                }
            }
        }
        .contentMargins(.bottom, 80, for: .scrollContent)
        .padding(.horizontal)
        .padding(.top, 32)
        .overlay(alignment: .bottom) {
            PrimaryButton("О рейтинге", variant: .capsule, action: { showAboutRating = true })
                .glassIfAvailable()
                .popover(isPresented: $showAboutRating) {
                    Text("Рейтинг — это оценка вашей работы на складе. Он складывается из скорости и качества выполнения операций: сборки, приёмки, раскладки и других.\nЧем меньше ошибок и простоев, тем выше рейтинг. Значение пересчитывается каждый день по итогам смен за последний месяц.\nРейтинг влияет на приоритет при выдаче заданий и на расчёт премий.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(width: 300)
                        .presentationCompactAdaptation(.popover)
                }
        }

    }

    private var chart: some View {
        Chart {
            ForEach(viewModel.history) { point in
                LineMark(
                    x: .value("Дата", point.date),
                    y: .value("Рейтинг", point.value)
                )
                .foregroundStyle(ColorPalette.accentPrimary)
                .lineStyle(.init(lineWidth: 4, lineCap: .round))
                .interpolationMethod(.catmullRom)
            }

            if let selectedPoint {
                RuleMark(x: .value("Дата", selectedPoint.date))
                    .foregroundStyle(ColorPalette.surfacePrimary.opacity(0.4))

                PointMark(
                    x: .value("Дата", selectedPoint.date),
                    y: .value("Рейтинг", selectedPoint.value)
                )
                .foregroundStyle(ColorPalette.surfacePrimary)
                .symbolSize(150)
                .annotation(
                    position: .automatic,
                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                ) {
                    VStack(spacing: 2) {
                        Text(
                            selectedPoint.value,
                            format: .number.precision(.fractionLength(0))
                        )
                        .font(.headline)
                        Text(
                            selectedPoint.date,
                            format: .dateTime.day().month()
                        )
                        .font(.caption)
                    }
                    .foregroundStyle(ColorPalette.brandPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        ColorPalette.surfacePrimary.opacity(0.9),
                        in: Capsule()
                    )
                    .glassIfAvailable()
                }
            }
        }
        .chartXAxis {
            AxisMarks {
                AxisValueLabel(anchor: .top)
                    .foregroundStyle(ColorPalette.surfacePrimary)
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisValueLabel()
                    .foregroundStyle(ColorPalette.surfacePrimary)

            }
        }
        .chartXScale(domain: viewModel.xDomain)
        .chartYScale(domain: viewModel.yDomain)
        .chartXSelection(value: $selectedDate)
        .chartGesture { proxy in
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let x = min(max(value.location.x, 0), proxy.plotSize.width)
                    proxy.selectXValue(at: x)
                }
        }
    }
}

#Preview {
    ProfileRatingView(service: ProfileRatingServiceMock())
}
