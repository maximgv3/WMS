import Foundation

nonisolated struct Profile: Decodable, Sendable {
    let name: String
    let imageUrl: URL

    let pendingFundsKopecks: Int
    let balanceFundsKopecks: Int

    let rating: Int

    enum CodingKeys: String, CodingKey {
        case name
        case imageUrl = "image_url"
        case pendingFundsKopecks = "pending_funds_kopecks"
        case balanceFundsKopecks = "balance_funds_kopecks"
        case rating
    }
}
