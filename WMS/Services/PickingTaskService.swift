import Foundation

protocol PickingTaskServiceProtocol: AnyObject {
    func fetchTask(userId: Int) async throws -> PickingTask
    func finishTask(collectedItems: [Item], skippedItems: [Item], userId: Int) async throws -> Void
}

final class PickingListServiceMock: PickingTaskServiceProtocol {

    private let mockItems: [Item] = MockData().mockItems
        
    func fetchTask(userId: Int) async throws -> PickingTask {
        try await Task.sleep(for: .seconds(0.1))
        
        if userId == 666 {
            throw NSError(domain: "PickingTask", code: 666, userInfo: [
                NSLocalizedDescriptionKey: "Задание недоступно для данного пользователя"
            ])
        }
        
        return PickingTask(allItems: mockItems)

    }
    
    func finishTask(collectedItems: [Item], skippedItems: [Item], userId: Int) async throws {
        try await Task.sleep(for: .seconds(0.5))
    }
    
}
