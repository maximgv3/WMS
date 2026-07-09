import Charts
import SwiftUI

struct ProfileRatingView: View {

    @State private var selectedDate: Date?
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
                ZStack {
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
                    VStack {
                        Text(selectedDate?.formatted() ?? "ничего не выбрано")
                    }
                }
            }
        }
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
        .chartYScale(domain: 4...25)
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
