import Foundation

protocol PickingTaskServiceProtocol: AnyObject {
    func fetchTask(userId: Int) async throws -> PickingTask
    func checkIfIdAvailableForReplacement(id: Int, replacementId: Int) async -> Bool
    func finishTask(result: PickingResult, userId: Int) async throws -> Void
}

final class PickingListServiceMock: PickingTaskServiceProtocol {

    private let mockItems: [Item] = MockData.mockItems

    func fetchTask(userId: Int) async throws -> PickingTask {
        try await Task.sleep(for: .seconds(0.1))

        if userId == 666 {
            throw NSError(domain: "PickingTask", code: 666, userInfo: [
                NSLocalizedDescriptionKey: "Задание недоступно для данного пользователя"
            ])
        }

        return PickingTask(allItems: mockItems)

    }

    func checkIfIdAvailableForReplacement(id: Int, replacementId: Int) async -> Bool {
        // In mock mode, only selected demo IDs are accepted as replacements.
        let allowedMockIds: Set<Int> = [111, 222, 333, 444, 555]
        try? await Task.sleep(for: .seconds(1.0))
        return allowedMockIds.contains(replacementId)
    }

    func finishTask(result: PickingResult, userId: Int) async throws {
        try await Task.sleep(for: .seconds(0.5))
        print("✅⬆ Successfully finished Picking Task with result: \(result)")
    }

}
