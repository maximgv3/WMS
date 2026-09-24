import Foundation
import Observation

@Observable
final class LoginViewModel {
    private let authService: AuthServiceProtocol

    private(set) var isLoading = false
    private(set) var lastError: AuthError?

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signIn(badgeId: String) async -> Bool {
        guard !isLoading else { return false }

        isLoading = true
        lastError = nil

        defer {
            isLoading = false
        }

        do {
            try await authService.signIn(badgeId: badgeId)
            return true
        } catch let error as AuthError {
            lastError = error
        } catch {
            print("Failed to sign in:", error)
        }

        return false
    }

    func clearError() {
        lastError = nil
    }
}
