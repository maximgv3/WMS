import Foundation

protocol TariffsServiceProtocol: AnyObject {
    func getTariffs() async throws -> [OperationTariff]
}

final class TariffsServiceMock: TariffsServiceProtocol {
    var errorThrowType: TariffsServiceMockError?
    var tariffs: [OperationTariff]

    init(
        errorThrowType: TariffsServiceMockError? = nil,
        tariffs: [OperationTariff] = MockData.operationTariffs
    ) {
        self.errorThrowType = errorThrowType
        self.tariffs = tariffs
    }

    func getTariffs() async throws -> [OperationTariff] {
        switch errorThrowType {
        case .loadingFailed:
            throw TariffsServiceMockError.loadingFailed
        case .cancellation:
            throw CancellationError()
        case nil:
            try await Task.sleep(for: .seconds(1))
            return tariffs
        }
    }

    enum TariffsServiceMockError: Error {
        case loadingFailed
        case cancellation
    }
}
