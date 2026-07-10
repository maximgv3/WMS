import Foundation

struct OperationRating: Identifiable {
    let name: String
    let value: Double
    let iconName: String
    let didGoUp: Bool?
    
    var id: String { name }
}
