import Foundation
import Observation

@Observable
final class ProfileRatingViewModel {
    private let service: ProfileRatingServiceProtocol

    var summary: ProfileRatingSummary?
    var isLoading = false
    var errorMessage: String?

    var history: [RatingPoint] { summary?.history ?? [] }
    var operations: [OperationRating] { summary?.operations ?? [] }

    init(service: ProfileRatingServiceProtocol) {
        self.service = service
    }

    func loadRating() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            summary = try await service.getRatingSummary()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var yDomain: ClosedRange<Double> {
        guard
            let minimum = history.map(\.value).min(),
            let maximum = history.map(\.value).max()
        else {
            return 0...1
        }
        return max(0, minimum - 2)...(maximum + 2)
    }

    var xDomain: ClosedRange<Date> {
        guard let first = history.first?.date, let last = history.last?.date else {
            let now = Date.now
            return now.addingTimeInterval(-30 * 24 * 60 * 60)...now
        }
        return first...last
    }

    func nearestPoint(to date: Date) -> RatingPoint? {
        history.min {
            abs($0.date.timeIntervalSince(date))
                < abs($1.date.timeIntervalSince(date))
        }
    }
}
