import Foundation

protocol ProfileRatingServiceProtocol: AnyObject {
    func getRatingSummary() async throws -> ProfileRatingSummary
}

final class ProfileRatingServiceMock: ProfileRatingServiceProtocol {
    var errorThrowType: ProfileRatingServiceMockError?
    var summary: ProfileRatingSummary

    init(
        errorThrowType: ProfileRatingServiceMockError? = nil,
        summary: ProfileRatingSummary = ProfileRatingSummary(
            history: MockData.ratingHistory,
            operations: MockData.operationsRatings
        )
    ) {
        self.errorThrowType = errorThrowType
        self.summary = summary
    }

    func getRatingSummary() async throws -> ProfileRatingSummary {
        switch errorThrowType {
        case .loadingFailed:
            throw ProfileRatingServiceMockError.loadingFailed
        case .cancellation:
            throw CancellationError()
        case nil:
            try await Task.sleep(for: .seconds(1))
            return summary
        }
    }

    enum ProfileRatingServiceMockError: Error {
        case loadingFailed
        case cancellation
    }
}
