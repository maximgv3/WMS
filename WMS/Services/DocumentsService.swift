import Foundation

protocol DocumentsServiceProtocol: AnyObject {
    func getDocuments() async throws -> [WarehouseDocument]
    func acknowledge(documentID: String) async throws
}

final class DocumentsServiceMock: DocumentsServiceProtocol {
    var errorThrowType: DocumentsServiceMockError?
    var documents: [WarehouseDocument]

    init(
        errorThrowType: DocumentsServiceMockError? = nil,
        documents: [WarehouseDocument] = MockData.warehouseDocuments
    ) {
        self.errorThrowType = errorThrowType
        self.documents = documents
    }

    func getDocuments() async throws -> [WarehouseDocument] {
        switch errorThrowType {
        case .loadingFailed:
            throw DocumentsServiceMockError.loadingFailed
        case .cancellation:
            throw CancellationError()
        default:
            try await Task.sleep(for: .seconds(1))
            return documents
        }
    }

    func acknowledge(documentID: String) async throws {
        switch errorThrowType {
        case .acknowledgeFailed:
            throw DocumentsServiceMockError.acknowledgeFailed
        case .cancellation:
            throw CancellationError()
        default:
            try await Task.sleep(for: .seconds(1))
            guard let index = documents.firstIndex(where: { $0.id == documentID }) else {
                return
            }
            documents[index].isAcknowledged = true
        }
    }

    enum DocumentsServiceMockError: Error {
        case loadingFailed
        case cancellation
        case acknowledgeFailed
    }
}
