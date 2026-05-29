import Foundation

struct Profile: Decodable, Sendable {
    let name: String
    let imageUrl: URL

    let pendingFunds: Int
    let balanceFunds: Int

    let rating: Int
}
