import SwiftData

enum ProgressDatabase {
    static let container: ModelContainer? = {
        do {
            return try ModelContainer(for: PickingProgressRecord.self)
        } catch {
            print("🛟⚠️ Failed to create container: \(error)")
            return nil
        }
    }()
}
