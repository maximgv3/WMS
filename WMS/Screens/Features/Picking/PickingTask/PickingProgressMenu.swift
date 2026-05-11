import SwiftUI

struct PickingProgressMenu: View {
    private var totalCount: Int
    private var collectedCount: Int
    private var skippedCount: Int
    private var progressPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(collectedCount + skippedCount) / Double(totalCount)
    }
    
    init(totalCount: Int, collectedCount: Int, skippedCount: Int) {
        self.totalCount = totalCount
        self.collectedCount = collectedCount
        self.skippedCount = skippedCount
    }
    
    var body: some View {
        Menu {
            Text("Собрано \(collectedCount) из \(totalCount)")
            Text("Пропущено \(skippedCount)")
        } label: {
            progressIndicator
        }
        .buttonStyle(.plain)
    }

    private var progressIndicator: some View {
        HStack(spacing: 10) {
            circularProgress
            Text(
                "\(collectedCount)/\(totalCount)"
            )
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(ColorPalette.brandPrimary)
            .monospacedDigit()
        }
        .padding(.leading, 9)
        .padding(.trailing, 11)
        .padding(.vertical, 5)
        .background(ColorPalette.surfacePrimary)
        .clipShape(Capsule())
        .fixedSize(horizontal: true, vertical: false)
        .animation(
            .easeInOut(duration: 0.25),
            value: progressPercentage
        )
    }

    private var circularProgress: some View {
        ZStack {
            Circle()
                .stroke(ColorPalette.brandMuted.opacity(0.22), lineWidth: 3)

            Circle()
                .trim(from: 0, to: progressPercentage)
                .stroke(
                    ColorPalette.brandMuted,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(
                    .easeInOut(duration: 0.25),
                    value: progressPercentage
                )
        }
        .frame(width: 16, height: 16)
    }
}

#Preview {
    PickingProgressMenu(totalCount: 10, collectedCount: 4, skippedCount: 0)
}
