import Foundation

protocol PickingTaskServiceProtocol: AnyObject {
    func fetchTask(userId: Int) async throws -> PickingTask
}

final class PickingListServiceMock: PickingTaskServiceProtocol {
    
    private let mockItems: [Item] = MockData().mockItems
        
    func fetchTask(userId: Int) async throws -> PickingTask {
        try await Task.sleep(for: .seconds(0.5))
        
        if userId == 666 {
            throw NSError(domain: "PickingTask", code: 666, userInfo: [
                NSLocalizedDescriptionKey: "Задание недоступно для данного пользователя"
            ])
        }
        
        return PickingTask(allItems: mockItems)

    }
    
}
