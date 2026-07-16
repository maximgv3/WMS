import Foundation
import Observation

@Observable
final class DocumentsViewModel {
    private let service: DocumentsServiceProtocol

    private(set) var documents: [WarehouseDocument] = []
    var isLoading = false
    var errorMessage: String?

    private var acknowledgingID: String?

    init(service: DocumentsServiceProtocol) {
        self.service = service
    }

    func loadDocuments() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            documents = try await service.getDocuments()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acknowledge(_ documentID: String) async {
        guard acknowledgingID == nil else { return }
        acknowledgingID = documentID
        errorMessage = nil
        defer { acknowledgingID = nil }

        do {
            try await service.acknowledge(documentID: documentID)
            markAcknowledged(documentID)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isAcknowledged(_ documentID: String) -> Bool {
        documents.first { $0.id == documentID }?.isAcknowledged == true
    }

    func isAcknowledging(_ documentID: String) -> Bool {
        acknowledgingID == documentID
    }

    private func markAcknowledged(_ documentID: String) {
        guard let index = documents.firstIndex(where: { $0.id == documentID }) else {
            return
        }
        documents[index].isAcknowledged = true
    }
}
