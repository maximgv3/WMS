import Foundation

struct Item: Identifiable, Hashable, Equatable {
    
    let id: Int
    let barcode: String
    let article: String
    let brand: String?
    let title: String
    let size: String?
    let color: String?
    let imageUrl: URL
    let placement: String?
}
