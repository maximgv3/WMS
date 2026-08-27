import Foundation

nonisolated struct ReturnsTask: Decodable, Sendable, Hashable {
    let items: [ReturnItem]
}
