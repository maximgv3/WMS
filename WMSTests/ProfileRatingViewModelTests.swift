import Foundation
import Testing
@testable import WMS

@MainActor
struct ProfileRatingViewModelTests {

    @Test
    func loadFillsSummary() async {
        let viewModel = makeViewModel()
        await viewModel.loadRating()

        #expect(viewModel.summary != nil)
        #expect(!viewModel.history.isEmpty)
    }

    @Test
    func successfulLoadDisablesLoader() async {
        let viewModel = makeViewModel()
        await viewModel.loadRating()

        #expect(viewModel.isLoading == false)
    }

    @Test
    func failedLoadSetsErrorMessage() async {
        let viewModel = makeViewModel(
            service: ProfileRatingServiceMock(errorThrowType: .loadingFailed)
        )
        await viewModel.loadRating()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.summary == nil)
    }

    @Test
    func cancellationDoesNotSetErrorMessage() async {
        let viewModel = makeViewModel(
            service: ProfileRatingServiceMock(errorThrowType: .cancellation)
        )
        await viewModel.loadRating()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.summary == nil)
    }

    @Test
    func emptyHistoryFallsBackToDefaultYDomain() async {
        let viewModel = makeViewModel(
            service: ProfileRatingServiceMock(
                summary: ProfileRatingSummary(history: [], operations: [])
            )
        )
        await viewModel.loadRating()

        #expect(viewModel.yDomain == 0...1)
    }

    @Test
    func nearestPointReturnsNilWhenHistoryEmpty() async {
        let viewModel = makeViewModel(
            service: ProfileRatingServiceMock(
                summary: ProfileRatingSummary(history: [], operations: [])
            )
        )
        await viewModel.loadRating()

        #expect(viewModel.nearestPoint(to: .now) == nil)
    }

    private func makeViewModel() -> ProfileRatingViewModel {
        makeViewModel(service: ProfileRatingServiceMock())
    }

    private func makeViewModel(
        service: ProfileRatingServiceMock
    ) -> ProfileRatingViewModel {
        .init(service: service)
    }
}
