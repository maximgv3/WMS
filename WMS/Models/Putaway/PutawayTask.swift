import Foundation

nonisolated struct PutawayTask: Decodable, Sendable, Hashable {
    let items: [Item]
    let cellCapacity: Int
    let container: PutawayContainer
    
    enum CodingKeys: String, CodingKey {
        case items
        case cellCapacity = "cell_capacity"
        case container
    }
}
