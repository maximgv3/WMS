import Foundation

class PickingTask: Hashable {
    let id: UUID = UUID()
    
    static func == (lhs: PickingTask, rhs: PickingTask) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
