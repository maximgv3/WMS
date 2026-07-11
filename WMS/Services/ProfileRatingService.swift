import Foundation

protocol ProfileRatingServiceProtocol: AnyObject {
    func getRatingSummary() async throws -> ProfileRatingSummary
}

final class ProfileRatingServiceMock: ProfileRatingServiceProtocol {
    func getRatingSummary() async throws -> ProfileRatingSummary {
        try await Task.sleep(for: .seconds(1))
        return ProfileRatingSummary(
            history: MockData.ratingHistory,
            operations: MockData.operationsRatings
        )
    }
}
