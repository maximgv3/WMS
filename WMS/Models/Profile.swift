import Foundation

struct Profile: Decodable, Sendable {
    let name: String
    let imageUrl: URL

    let pendingFunds: Int
    let balanceFunds: Int

    let rating: Int

    enum CodingKeys: String, CodingKey {
        case name
        case imageUrl = "image_url"
        case pendingFunds = "pending_funds"
        case balanceFunds = "balance_funds"
        case rating
    }
}
