import Foundation

nonisolated struct ProfileRatingSummary: Sendable {
    let history: [RatingPoint]
    let operations: [OperationRating]
}
