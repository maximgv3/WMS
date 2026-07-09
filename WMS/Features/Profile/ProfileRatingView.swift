import Charts
import SwiftUI

struct ProfileRatingView: View {

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
                        Text(
                            "1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1"
                        )
                    }
                }
            }
        }
    }

    private var chart: some View {
        Chart(MockData.ratingHistory) { point in
            LineMark(
                x: .value("Дата", point.date),
                y: .value("Рейтинг", point.value)
            )
            .foregroundStyle(ColorPalette.accentPrimary)
            .lineStyle(.init(lineWidth: 4, lineCap: .round))
            .interpolationMethod(.catmullRom)
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
        .chartYScale(domain: 4...25)
    }
}

#Preview {
    ProfileRatingView()
}
