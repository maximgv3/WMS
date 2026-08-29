import Foundation

protocol ReturnsTaskServiceProtocol: AnyObject {
    func fetchTask(userId: Int) async throws -> ReturnsTask
    func finishTask(result: ReturnsResult, userId: Int) async throws
}

final class ReturnsTaskServiceMock: ReturnsTaskServiceProtocol {

    func fetchTask(userId: Int) async throws -> ReturnsTask {
        try await Task.sleep(for: .seconds(0.1))

        if userId == 666 {
            throw NSError(
                domain: "ReturnsTask",
                code: 666,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Задание недоступно для данного пользователя"
                ]
            )
        }

        return try MockJSONLoader.decode(ReturnsTask.self, from: "returns_task")
    }

    func finishTask(result: ReturnsResult, userId: Int) async throws {
        if userId == 666 {
            try await Task.sleep(for: .seconds(0.5))
            throw NSError(
                domain: "ReturnsTask",
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
            print("✅⬆ Successfully encoded Returns Task finish request:")
            print(jsonString)
        }
    }

    private func makeFinishRequest(from result: ReturnsResult, userId: Int)
        -> ReturnsTaskResultRequest
    {
        ReturnsTaskResultRequest(
            userId: userId,
            containerId: result.sourceContainerId,
            skippedItemIds: result.skippedItemIds,
            checks: result.decisions
                .map { itemId, decision in
                    ReturnCheck(
                        itemId: itemId,
                        decision: decision.rawValue,
                        containerId: result.containers[itemId],
                        photo: result.photos[itemId]
                    )
                }
                .sorted { $0.itemId < $1.itemId }
        )
    }
}
