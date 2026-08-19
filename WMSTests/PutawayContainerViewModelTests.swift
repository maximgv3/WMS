import Foundation
import Testing

@testable import WMS

@MainActor
struct PutawayContainerViewModelTests {

    private let containerId = "WMSCT481203"

    @Test
    func containerCodeIsAccepted() {
        let viewModel = makeViewModel()

        viewModel.processCode(containerId)

        #expect(viewModel.lastError == nil)
    }

    @Test
    func anotherContainerCodeFailsWithWrongContainer() {
        let viewModel = makeViewModel()

        viewModel.processCode("WMSCT000111")

        #expect(viewModel.lastError == .wrongContainer)
    }

    @Test
    func itemCodeFailsWithWrongContainer() {
        let viewModel = makeViewModel()

        viewModel.processCode("7839201741")

        #expect(viewModel.lastError == .wrongContainer)
    }

    @Test
    func containerCodeAfterMistakeClearsError() {
        let viewModel = makeViewModel()

        viewModel.processCode("WMSCT000111")
        viewModel.processCode(containerId)

        #expect(viewModel.lastError == nil)
    }

    @Test
    func clearErrorResetsLastError() {
        let viewModel = makeViewModel()

        viewModel.processCode("WMSCT000111")
        viewModel.clearError()

        #expect(viewModel.lastError == nil)
    }

    private func makeViewModel() -> PutawayContainerViewModel {
        PutawayContainerViewModel(
            container: PutawayContainer(id: containerId, location: "")
        )
    }
}
