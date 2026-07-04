import Foundation

nonisolated struct Item: Identifiable, Hashable, Equatable, Sendable, Codable {
    
    let id: Int
    let barcode: String
    let article: String
    let brand: String?
    let title: String
    let size: String?
    let color: String?
    let imageUrl: URL
    let placement: String?
    let price: Double
    let stock: Int

    enum CodingKeys: String, CodingKey {
        case id
        case barcode
        case article
        case brand
        case title
        case size
        case color
        case imageUrl = "image_url"
        case placement
        case price
        case stock
    }
}
