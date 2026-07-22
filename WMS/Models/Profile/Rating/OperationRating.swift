import Foundation

nonisolated struct OperationRating: Identifiable, Sendable {
    let name: String
    let value: Double
    let iconName: String
    let didGoUp: Bool?
    
    var id: String { name }
}
