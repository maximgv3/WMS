import SwiftUI

struct TaskProgressMenu<MenuContent: View>: View {
    
    private let doneCount: Int
    private let totalCount: Int
    private let menuContent: MenuContent
    
    private var progressPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(doneCount) / Double(totalCount)
    }
    
    init(doneCount: Int, totalCount: Int, @ViewBuilder menuContent: () -> MenuContent ) {
        self.doneCount = doneCount
        self.totalCount = totalCount
        self.menuContent = menuContent()
    }
    
    var body: some View {
        Menu { menuContent } label: { progressIndicator }
        .buttonStyle(.plain)
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 10) {
            circularProgress
            Text(
                "\(doneCount)/\(totalCount)"
            )
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(ColorPalette.brandPrimary)
            .monospacedDigit()
        }
        .padding(.leading, 9)
        .padding(.trailing, 11)
        .padding(.vertical, 5)
        .background(.clear)
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
TaskProgressMenu(doneCount: 6, totalCount: 10, menuContent: { Text("Собрано 6 из 10") })
}
