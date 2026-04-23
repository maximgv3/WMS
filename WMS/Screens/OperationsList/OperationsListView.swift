import SwiftUI

struct OperationsListView: View {
    
    private let operations = OperationType.allCases
    
    var body: some View {
        NavigationStack {
            List(operations) { operation in
                NavigationLink {
                    destination(for: operation)
                } label: {
                    HStack {
                        Image(systemName: operation.iconName)
                        Text(operation.title)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Операции")
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
