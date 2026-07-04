import Foundation

struct OperationMenuItem: Identifiable {
    let operation: OperationType
    let isEnabled: Bool
    
    var id: OperationType { operation }
}
