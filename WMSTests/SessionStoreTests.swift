import Foundation
import Testing
@testable import WMS

@MainActor
struct SessionStoreTests {
    @Test
    func freshInstallIsSignedOut() throws {
        let store = SessionStore(userDefaults: try makeUserDefaults())

        #expect(store.isSignedIn == false)
    }

    @Test
    func signInIsKeptBetweenLaunches() throws {
        let userDefaults = try makeUserDefaults()
        SessionStore(userDefaults: userDefaults).signIn(badgeId: "1023780")

        let relaunchedStore = SessionStore(userDefaults: userDefaults)

        #expect(relaunchedStore.badgeId == "1023780")
    }

    @Test
    func signOutIsKeptBetweenLaunches() throws {
        let userDefaults = try makeUserDefaults()
        let store = SessionStore(userDefaults: userDefaults)
        store.signIn(badgeId: "1023780")
        store.signOut()

        let relaunchedStore = SessionStore(userDefaults: userDefaults)

        #expect(relaunchedStore.isSignedIn == false)
    }

    private func makeUserDefaults(
        _ testName: String = #function
    ) throws -> UserDefaults {
        let suiteName = "SessionStoreTests.\(testName)"
        let userDefaults = try #require(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}
