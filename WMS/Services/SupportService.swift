import Foundation

protocol SupportServiceProtocol: AnyObject {
    func getMessages() async throws -> [ChatMessage]
    func send(_ text: String) async throws -> ChatMessage
}

final class SupportServiceMock: SupportServiceProtocol {
    var errorThrowType: SupportServiceMockError?
    private var messages: [ChatMessage]

    init(
        errorThrowType: SupportServiceMockError? = nil,
        messages: [ChatMessage] = MockData.supportMessages
    ) {
        self.errorThrowType = errorThrowType
        self.messages = messages
    }

    func getMessages() async throws -> [ChatMessage] {
        try await Task.sleep(for: .seconds(0.5))
        switch errorThrowType {
        case .loadingFailed:
            throw SupportServiceMockError.loadingFailed
        case .cancellation:
            throw CancellationError()
        default:
            return messages
        }
    }

    func send(_ text: String) async throws -> ChatMessage {
        try await Task.sleep(for: .seconds(1))
        switch errorThrowType {
        case .sendFailed:
            throw SupportServiceMockError.sendFailed
        case .cancellation:
            throw CancellationError()
        default:
            let message = ChatMessage(
                date: .now,
                fromUser: true,
                text: text,
                id: UUID().uuidString
            )
            messages.append(message)
            return message
        }
    }

    enum SupportServiceMockError: Error {
        case loadingFailed
        case sendFailed
        case cancellation
    }
}
