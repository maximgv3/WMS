import Charts
import SwiftUI

struct ProfileRatingView: View {

    @State private var selectedDate: Date?
    @State private var showAboutRating = false
    
    private var selectedPoint: RatingPoint? {
        guard let selectedDate else { return nil }
        return ratingHistory.min {
            abs($0.date.timeIntervalSince(selectedDate))
                < abs($1.date.timeIntervalSince(selectedDate))
        }
    }
    
    private let ratingHistory = MockData.ratingHistory

    var body: some View {
        ZStack {
            ColorPalette.brandPrimary.ignoresSafeArea()
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
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    private var operationsGrid: some View {
        
        ScrollView {
            VStack(spacing: 40) {
                Text("Рейтинг по операциям")
                    .font(.title3).bold()
                LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                    ForEach(MockData.operationsRatings) { operation in
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
    private var ratingYDomain: (Double, Double) {
        guard
            let minimum = ratingHistory.map(\.value).min(),
            let maximum = ratingHistory.map(\.value).max()
        else {
            return (0, 1)
        }

        return (max(0, (minimum - 2)), (maximum + 2))
    }
    
    private var chart: some View {
        Chart(ratingHistory) { point in
            LineMark(
                x: .value("Дата", point.date),
                y: .value("Рейтинг", point.value)
            )
            .foregroundStyle(ColorPalette.accentPrimary)
            .lineStyle(.init(lineWidth: 4, lineCap: .round))
            .interpolationMethod(.catmullRom)

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
                    .glassIfAvailable()
                }
            }
        }
        .chartXAxis {
            AxisMarks {
                AxisValueLabel()
                    .foregroundStyle(ColorPalette.surfacePrimary)
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisValueLabel()
                    .foregroundStyle(ColorPalette.surfacePrimary)

            }
        }
        .chartXScale(
            domain: ratingHistory.first!.date...ratingHistory.last!.date
        )
        .chartYScale(domain: ratingYDomain.0...ratingYDomain.1)
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
    ProfileRatingView()
}
