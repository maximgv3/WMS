import Foundation

nonisolated struct PutawayContainer: Decodable, Sendable, Hashable {
    let id: String
    let location: String
}
