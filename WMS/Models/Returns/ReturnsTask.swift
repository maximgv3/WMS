import Foundation

nonisolated struct ReturnsTask: Decodable, Sendable, Hashable {
    let container: ReturnsContainer
    let items: [ReturnItem]
}
