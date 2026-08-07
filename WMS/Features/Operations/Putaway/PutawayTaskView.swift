import SwiftUI

struct PutawayTaskView: View {
    @State var isScanningEnabled: Bool = false
    
    var body: some View {
        VStack {
            storageCellCard
            Spacer()
            ScannerView(isScanningEnabled: $isScanningEnabled, idleText: "Сканируйте", activeText: "Сканируем", onScan:{_ in })
        }
        .padding(16)
    }
    
    @State var temp = true
    private var progressValue: Double {
        return 0.75
    }
    
    private var storageCellCard: some View {
        ZStack {
            VStack(spacing: 12) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 40, weight: .light))
                Text("Ячейка не выбрана")
                    .font(.system(size: 20, weight: .medium))
            }
            .foregroundStyle(ColorPalette.brandPrimary)
            .frame(maxWidth: .infinity, minHeight: 140)
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        ColorPalette.brandPrimary,
                        style: StrokeStyle(lineWidth: 2, dash: [6])
                    )
            }
            .opacity(temp ? 0 : 1)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ячейка")
                    Spacer()
                    changeCellButton
                        .padding(.horizontal, -6)
                }
                Text("АЛ.21.04.21.05.01")
                    .font(.system(size: 24, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                ProgressView(value: progressValue)
                    .tint(ColorPalette.accentPrimary)
                Text("3 из 4")
            }
            .padding(.horizontal, 16)
            .foregroundStyle(ColorPalette.brandPrimary)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(ColorPalette.accentPrimary.opacity(0.18)))
            .opacity(temp ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .task {
            while true {
                try? await Task.sleep(for: .seconds(1))
                temp.toggle()
            }
        }
    }
    
    private var changeCellButton: some View {
        Button {
            
        } label: {
            Text("Сменить ячейку")
                .padding(6)
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(ColorPalette.brandPrimary, lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .glassIfAvailable(shape: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    PutawayTaskView()
}
