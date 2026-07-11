import SwiftUI

struct OperationRatingCell: View {
    let operation: OperationRating

    var body: some View {
        HStack(spacing: 12) {
            IconChip(systemName: operation.iconName, size: 40)
                .overlay(alignment: .topTrailing) {
                    image
                        .offset(x: 6, y: -6)
                }
            VStack(alignment: .leading) {
                Text(operation.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(operation.value, format: .number.precision(.fractionLength(2)))
                    .font(.callout)
            }
        }
    }
    
    private var trend: (icon: String, color: Color) {
        switch operation.didGoUp {
        case true?:  ("arrow.up.circle.fill", ColorPalette.success)
        case false?: ("arrow.down.circle.fill", ColorPalette.error)
        case nil:    ("equal.circle.fill", ColorPalette.brandSecondary)
        }
    }
    
    private var image: some View {

        return Image(systemName: trend.icon)
            .foregroundStyle(trend.color)
    }
}

#Preview {
    VStack(alignment: .leading) {
        OperationRatingCell(operation: MockData.operationsRatings[0])
        OperationRatingCell(operation: MockData.operationsRatings[1])
        OperationRatingCell(operation: MockData.operationsRatings[2])
    }
    .padding(16)
}
