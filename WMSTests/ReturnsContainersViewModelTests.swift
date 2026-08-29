import Foundation
import Testing

@testable import WMS

@MainActor
struct ReturnsContainersViewModelTests {

    private let sourceContainerId = "WMSCT620814"

    @Test
    func anotherContainerCodeFailsWithWrongContainer() {
        let viewModel = makeViewModel()

        viewModel.processCode("WMSCT000111")

        #expect(viewModel.lastError == .wrongContainer)
        #expect(viewModel.isContainerScanned == false)
    }

    @Test
    func sourceContainerCodeIsAccepted() {
        let viewModel = makeViewModel()

        viewModel.processCode(sourceContainerId)

        #expect(viewModel.lastError == nil)
        #expect(viewModel.isContainerScanned)
        #expect(viewModel.nextSlot == .good)
    }

    @Test
    func slotsAreBoundInOrder() {
        let viewModel = makeViewModel()

        viewModel.processCode(sourceContainerId)
        viewModel.processCode("WMSCT770145")
        #expect(viewModel.nextSlot == .inspection)

        viewModel.processCode("WMSCT770238")

        #expect(viewModel.nextSlot == nil)
        #expect(
            viewModel.containers
                == ReturnsContainers(
                    good: "WMSCT770145",
                    inspection: "WMSCT770238"
                )
        )
    }

    @Test
    func itemCodeFailsWithNotAContainer() {
        let viewModel = makeViewModel()

        viewModel.processCode(sourceContainerId)
        viewModel.processCode("7839201741")

        #expect(viewModel.lastError == .notAContainer)
        #expect(viewModel.nextSlot == .good)
    }

    @Test
    func alreadyUsedContainerIsRejected() {
        let viewModel = makeViewModel()

        viewModel.processCode(sourceContainerId)
        viewModel.processCode("WMSCT770145")
        viewModel.processCode("WMSCT770145")
        #expect(viewModel.lastError == .containerAlreadyUsed)

        viewModel.processCode(sourceContainerId)

        #expect(viewModel.lastError == .containerAlreadyUsed)
        #expect(viewModel.nextSlot == .inspection)
    }

    @Test
    func containersAreNotReadyUntilBothSlotsAreBound() {
        let viewModel = makeViewModel()

        viewModel.processCode(sourceContainerId)
        viewModel.processCode("WMSCT770145")

        #expect(viewModel.containers == nil)
    }

    @Test
    func clearErrorResetsLastError() {
        let viewModel = makeViewModel()

        viewModel.processCode("WMSCT000111")
        viewModel.clearError()

        #expect(viewModel.lastError == nil)
    }

    private func makeViewModel() -> ReturnsContainersViewModel {
        ReturnsContainersViewModel(
            container: ReturnsContainer(id: sourceContainerId, location: "")
        )
    }
}
