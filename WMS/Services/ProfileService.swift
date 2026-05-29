import Foundation

protocol ProfileServiceProtocol {
    func getProfile() async throws -> Profile
}

final class ProfileServiceMock: ProfileServiceProtocol {

    func getProfile() async throws -> Profile {
        try await Task.sleep(for: .seconds(1))
        return MockData.profileMock
    }
}
