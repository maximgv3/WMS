import Foundation

nonisolated struct RatingPoint: Identifiable, Sendable {
    let date: Date
    let value: Double
    
    var id: Date { date }
}
