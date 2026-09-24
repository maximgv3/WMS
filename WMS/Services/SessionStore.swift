import Foundation
import Observation

@Observable
final class SessionStore {
    private(set) var badgeId: String?
    var isSignedIn: Bool { badgeId != nil }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        badgeId = userDefaults.string(forKey: AppSettings.Key.signedInBadgeId)
    }

    func signIn(badgeId: String) {
        self.badgeId = badgeId
        userDefaults.set(badgeId, forKey: AppSettings.Key.signedInBadgeId)
    }

    func signOut() {
        badgeId = nil
        userDefaults.removeObject(forKey: AppSettings.Key.signedInBadgeId)
    }
}
