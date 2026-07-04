import Foundation

protocol PickingTaskServiceProtocol: AnyObject {
    func fetchTask(userId: Int) async throws -> PickingTask
    func checkIfIdAvailableForReplacement(id: Int, replacementId: Int) async
        -> Bool
    func finishTask(result: PickingResult, userId: Int) async throws
}

final class PickingListServiceMock: PickingTaskServiceProtocol {

    func fetchTask(userId: Int) async throws -> PickingTask {
        try await Task.sleep(for: .seconds(0.1))

        if userId == 666 {
            throw NSError(
                domain: "PickingTask",
                code: 666,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Задание недоступно для данного пользователя"
                ]
            )
        }

        return try MockJSONLoader.decode(PickingTask.self, from: "picking_task")

    }

    func checkIfIdAvailableForReplacement(id: Int, replacementId: Int) async
        -> Bool
    {
        // In mock mode, only selected demo IDs are accepted as replacements.
        let allowedMockIds: Set<Int> = [111, 222, 333, 444, 555]
        try? await Task.sleep(for: .seconds(1.0))
        return allowedMockIds.contains(replacementId)
    }

    func finishTask(result: PickingResult, userId: Int) async throws {
        if userId == 666 {
            try await Task.sleep(for: .seconds(0.5))
            throw NSError(
                domain: "PickingTask",
                code: 666,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Не удалось отправить результат для данного пользователя"
                ]
            )
        }

        let request = makeFinishRequest(from: result, userId: userId)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(request)
        try await Task.sleep(for: .seconds(0.5))
        if let jsonString = String(data: data, encoding: .utf8) {
            print("✅⬆ Successfully encoded Picking Task finish request:")
            print(jsonString)
        }
    }

    private func makeFinishRequest(from result: PickingResult, userId: Int)
        -> PickingTaskResultRequest
    {
        PickingTaskResultRequest(
            userId: userId,
            collectedItemIds: result.collectedItems.map(\.id),
            skippedItemIds: result.skippedItems.map(\.id),
            replacements: result.replacements.map {
                originalItem,
                replacementId in
                Replacement(
                    originalItemId: originalItem.id,
                    replacementId: replacementId
                )
            }
        )
    }
}
