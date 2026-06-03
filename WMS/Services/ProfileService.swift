import Foundation

protocol ProfileServiceProtocol {
    func getProfile() async throws -> Profile
}

final class ProfileServiceMock: ProfileServiceProtocol {
    var errorThrowType: ProfileServiceMockError?

    init(errorThrowType: ProfileServiceMockError? = nil) {
        self.errorThrowType = errorThrowType
    }

    func getProfile() async throws -> Profile {
        switch errorThrowType {
        case .loadingFailed:
            throw ProfileServiceMockError.loadingFailed
        case .cancellation:
            throw CancellationError()
        case nil:
            try await Task.sleep(for: .seconds(0.25))
            return MockData.profileMock
        }
    }

    enum ProfileServiceMockError: Error {
        case loadingFailed
        case cancellation
    }
}
