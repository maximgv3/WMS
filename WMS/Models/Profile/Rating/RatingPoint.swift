import Foundation

struct RatingPoint: Identifiable {
    let date: Date
    let value: Double
    
    var id: Date { date }
}
