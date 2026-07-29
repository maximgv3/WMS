import Foundation

protocol SupportServiceProtocol: AnyObject {
    var incomingMessages: AsyncStream<ChatMessage> { get }
    func getMessages() async throws -> [ChatMessage]
    func send(_ text: String) async throws -> ChatMessage
}

final class SupportServiceMock: SupportServiceProtocol {
    var errorThrowType: SupportServiceMockError?
    private var messages: [ChatMessage]
    let incomingMessages: AsyncStream<ChatMessage>
    private let continuation: AsyncStream<ChatMessage>.Continuation

    init(
        errorThrowType: SupportServiceMockError? = nil,
        messages: [ChatMessage] = MockData.firstSupportMessages
    ) {
        self.errorThrowType = errorThrowType
        self.messages = messages
        let (stream, continuation) = AsyncStream.makeStream(
            of: ChatMessage.self
        )
        self.incomingMessages = stream
        self.continuation = continuation
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
            sendMockSupportReply()
            return message
        }
    }

    private func sendMockSupportReply() {
        Task {
            do {
                for message in MockData.replySupportMessages {
                    try await Task.sleep(for: .seconds((1...3).randomElement() ?? 1))
                    continuation.yield(message)
                }
            } catch { }
        }
    }

    enum SupportServiceMockError: Error {
        case loadingFailed
        case sendFailed
        case cancellation
    }
}
