import Foundation

protocol PickingTaskServiceProtocol: AnyObject {
    func fetchTask(userId: Int) async throws -> PickingTask
}

final class PickingListServiceMock: PickingTaskServiceProtocol {
    
    private let mockPickingTask = PickingTask()
    
    func fetchTask(userId: Int) async throws -> PickingTask {
        try await Task.sleep(for: .seconds(2))
        return mockPickingTask
    }
    
}
