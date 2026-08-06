import Foundation

protocol PutawayTaskServiceProtocol: AnyObject {
    func fetchTask(userId: Int) async throws -> PutawayTask
    func finishTask(userId: Int, result: PutawayResult) async throws
}

final class PutawayTaskServiceMock: PutawayTaskServiceProtocol {

    func fetchTask(userId: Int) async throws -> PutawayTask {
        try await Task.sleep(for: .seconds(0.1))

        if userId == 666 {
            throw NSError(
                domain: "PutawayTask",
                code: 666,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Задание недоступно для данного пользователя"
                ]
            )
        }

        return try MockJSONLoader.decode(PutawayTask.self, from: "putaway_task")
    }

    func finishTask(userId: Int, result: PutawayResult) async throws {
        if userId == 666 {
            try await Task.sleep(for: .seconds(0.5))
            throw NSError(
                domain: "PutawayTask",
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
            print("✅⬆ Successfully encoded Putaway Task finish request:")
            print(jsonString)
        }
    }

    private func makeFinishRequest(from result: PutawayResult, userId: Int)
        -> PutawayTaskResultRequest
    {
        PutawayTaskResultRequest(
            userId: userId,
            placements: result.placedItems
                .map { item, cell in
                    Placement(itemId: item.id, cell: cell)
                }
                .sorted { $0.itemId < $1.itemId }
        )
    }
}
