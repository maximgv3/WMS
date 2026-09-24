protocol AuthServiceProtocol {
    func signIn(badgeId: String) async throws
}

final class AuthServiceMock: AuthServiceProtocol {
    let errorType: AuthServiceMockError?

    init(throwErrorType: AuthServiceMockError? = nil) {
        self.errorType = throwErrorType
    }

    func signIn(badgeId: String) async throws {
        try await Task.sleep(for: .seconds(0.3))
        if errorType == .alreadyAuthorizedOnOtherDevice {
            throw AuthError.alreadyAuthorizedOnOtherDevice
        }
        let operators = try MockJSONLoader.decode([String].self, from: "operators")
        guard operators.contains(badgeId) else {
            throw AuthError.unknownId
        }
    }
}

enum AuthServiceMockError {
    case alreadyAuthorizedOnOtherDevice
}
