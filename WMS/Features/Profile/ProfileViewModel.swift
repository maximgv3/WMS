import Foundation
import Observation

@Observable
final class ProfileViewModel {
    private let profileService: ProfileServiceProtocol

    var profile: Profile?
    var isLoading = false
    var errorMessage: String?
    var lastUpdateDate = Date.now

    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
    }

    func loadProfile() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            profile = try await profileService.getProfile()
            lastUpdateDate = .now
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
