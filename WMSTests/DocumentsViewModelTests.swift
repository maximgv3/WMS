import Foundation
import Testing
@testable import WMS

@MainActor
struct DocumentsViewModelTests {

    @Test
    func loadFillsDocuments() async {
        let viewModel = makeViewModel()
        await viewModel.loadDocuments()

        #expect(!viewModel.documents.isEmpty)
    }

    @Test
    func successfulLoadDisablesLoader() async {
        let viewModel = makeViewModel()
        await viewModel.loadDocuments()

        #expect(viewModel.isLoading == false)
    }

    @Test
    func failedLoadSetsErrorMessage() async {
        let viewModel = makeViewModel(
            service: DocumentsServiceMock(errorThrowType: .loadingFailed)
        )
        await viewModel.loadDocuments()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.documents.isEmpty)
    }

    @Test
    func cancellationDoesNotSetErrorMessage() async {
        let viewModel = makeViewModel(
            service: DocumentsServiceMock(errorThrowType: .cancellation)
        )
        await viewModel.loadDocuments()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.documents.isEmpty)
    }

    @Test
    func acknowledgeMarksDocumentAsRead() async {
        let document = makeDocument()
        let viewModel = makeViewModel(
            service: DocumentsServiceMock(documents: [document])
        )
        await viewModel.loadDocuments()
        await viewModel.acknowledge(document.id)

        #expect(viewModel.isAcknowledged(document.id))
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func failedAcknowledgeKeepsDocumentUnread() async {
        let document = makeDocument()
        let viewModel = makeViewModel(
            service: DocumentsServiceMock(
                errorThrowType: .acknowledgeFailed,
                documents: [document]
            )
        )
        await viewModel.loadDocuments()
        await viewModel.acknowledge(document.id)

        #expect(viewModel.isAcknowledged(document.id) == false)
        #expect(viewModel.errorMessage != nil)
    }

    private func makeDocument() -> WarehouseDocument {
        .init(
            title: "Инструкция по охране труда",
            fileName: "safety_instruction",
            updatedAt: .now,
            isAcknowledged: false
        )
    }

    private func makeViewModel() -> DocumentsViewModel {
        makeViewModel(service: DocumentsServiceMock())
    }

    private func makeViewModel(
        service: DocumentsServiceMock
    ) -> DocumentsViewModel {
        .init(service: service)
    }
}
