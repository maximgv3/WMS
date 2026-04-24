import SwiftUI

struct OperationsListView: View {
    
    private let operations = OperationType.allCases
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.brandPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    customTopBar

                    operationsList
                        .background(ColorPalette.surfacePrimary)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 28,
                                topTrailingRadius: 28
                            )
                        )
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var customTopBar: some View {
        HStack {
            Text("Операции")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(ColorPalette.brandPrimary)
    }

    private var operationsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(operations.enumerated()), id: \.element.id) { index, operation in
                    NavigationLink {
                        destination(for: operation)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(ColorPalette.accentPrimary.opacity(0.18))
                                    .frame(width: 36, height: 36)

                                Image(systemName: operation.iconName)
                                    .foregroundStyle(ColorPalette.brandPrimary)
                            }

                            Text(operation.title)
                                .foregroundStyle(ColorPalette.brandPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWeight(.medium)

                            Image(systemName: "chevron.right")
                                .foregroundStyle(ColorPalette.brandMuted.opacity(0.75))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < operations.count - 1 {
                        Divider()
                            .padding(.leading, 64)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }
    
    @ViewBuilder
    private func destination(for operation: OperationType) -> some View {
        switch operation {
        case .picking:
            PickingModuleView()
        case .receiving:
            ReceivingModuleView()
        case .inventory:
            InventoryModuleView()
        }
    }
}

#Preview {
    OperationsListView()
}
