import Foundation
import Testing
@testable import WMS

@MainActor
struct ProfileViewModelTests {
    @Test
    func loadFillsProfile() async {
        let viewModel = makeViewModel()
        await viewModel.loadProfile()

        #expect(viewModel.profile != nil)
    }

    @Test
    func successfulLoadUpdatesDate() async {
        let viewModel = makeViewModel()
        let oldDate = viewModel.lastUpdateDate
        await viewModel.loadProfile()

        #expect(viewModel.lastUpdateDate > oldDate)
    }

    @Test
    func successfulLoadDisablesLoader() async {
        let viewModel = makeViewModel()
        await viewModel.loadProfile()

        #expect(viewModel.isLoading == false)
    }

    @Test
    func failedLoadSetsErrorMessage() async {
        let service = ProfileServiceMock(errorThrowType: .loadingFailed)
        let viewModel = makeViewModel(service: service)
        await viewModel.loadProfile()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.profile == nil)
    }

    @Test
    func cancellationDoesNotSetErrorMessage() async {
        let service = ProfileServiceMock(errorThrowType: .cancellation)
        let viewModel = makeViewModel(service: service)
        await viewModel.loadProfile()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.profile == nil)
    }

    private func makeViewModel() -> ProfileViewModel {
        makeViewModel(service: ProfileServiceMock())
    }

    private func makeViewModel(service: ProfileServiceMock) -> ProfileViewModel {
        .init(profileService: service)
    }
}
