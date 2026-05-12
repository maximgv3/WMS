import Foundation

nonisolated struct Item: Identifiable, Hashable, Equatable, Sendable {
    
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
}
