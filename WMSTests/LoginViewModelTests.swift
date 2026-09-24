import Foundation
import Testing
@testable import WMS

@MainActor
struct LoginViewModelTests {
    private let knownBadgeId = "1023780"
    private let unknownBadgeId = "0000000000"

    @Test
    func knownBadgeSignsIn() async {
        let viewModel = makeViewModel()
        let isSignedIn = await viewModel.signIn(badgeId: knownBadgeId)

        #expect(isSignedIn)
        #expect(viewModel.lastError == nil)
    }

    @Test
    func unknownBadgeSetsError() async {
        let viewModel = makeViewModel()
        let isSignedIn = await viewModel.signIn(badgeId: unknownBadgeId)

        #expect(isSignedIn == false)
        #expect(viewModel.lastError == .unknownId)
    }

    @Test
    func accountInUseSetsError() async {
        let service = AuthServiceMock(
            throwErrorType: .alreadyAuthorizedOnOtherDevice
        )
        let viewModel = makeViewModel(service: service)
        let isSignedIn = await viewModel.signIn(badgeId: knownBadgeId)

        #expect(isSignedIn == false)
        #expect(viewModel.lastError == .alreadyAuthorizedOnOtherDevice)
    }

    @Test
    func signInDisablesLoader() async {
        let viewModel = makeViewModel()
        _ = await viewModel.signIn(badgeId: knownBadgeId)

        #expect(viewModel.isLoading == false)
    }

    @Test
    func repeatedScanWhileLoadingIsIgnored() async {
        let viewModel = makeViewModel()
        let firstScan = Task { await viewModel.signIn(badgeId: knownBadgeId) }
        await Task.yield()

        let isSecondScanAccepted = await viewModel.signIn(badgeId: knownBadgeId)

        #expect(isSecondScanAccepted == false)
        #expect(await firstScan.value)
    }

    @Test
    func clearErrorResetsError() async {
        let viewModel = makeViewModel()
        _ = await viewModel.signIn(badgeId: unknownBadgeId)
        viewModel.clearError()

        #expect(viewModel.lastError == nil)
    }

    private func makeViewModel() -> LoginViewModel {
        makeViewModel(service: AuthServiceMock())
    }

    private func makeViewModel(service: AuthServiceMock) -> LoginViewModel {
        .init(authService: service)
    }
}
