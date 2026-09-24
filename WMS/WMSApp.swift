import SwiftUI

@main
struct WMSApp: App {
    @State private var activeTaskStore = ActiveTaskStore()
    @State private var sessionStore = SessionStore()

    init() {
        AppSettings.registerDefaults()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(sessionStore)
                .environment(activeTaskStore)
        }
    }
}
