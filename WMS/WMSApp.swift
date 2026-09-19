import SwiftUI

@main
struct WMSApp: App {
    @State private var activeTaskStore = ActiveTaskStore()

    init() {
        AppSettings.registerDefaults()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(activeTaskStore)
        }
    }
}
