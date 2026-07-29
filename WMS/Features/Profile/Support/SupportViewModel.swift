import Observation
import SwiftUI

@Observable
final class SupportViewModel {
    private let service: SupportServiceProtocol
    var messages: [ChatMessage] = []
    var isLoading = false
    var errorMessage: String?
    var replyDraft = ""

    init(service: SupportServiceProtocol) {
        self.service = service
    }

    func loadMessages() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            messages = try await service.getMessages()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func send() async {
        let draft = replyDraft
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let temporary = ChatMessage(
            date: .now,
            fromUser: true,
            text: text,
            id: UUID().uuidString
        )
        withAnimation(.snappy(duration: 0.25)) {
            messages.append(temporary)
        }
        replyDraft = ""

        do {
            let sent = try await service.send(text)
            if let index = messages.firstIndex(where: { $0.id == temporary.id }) {
                messages[index] = sent
            }
        } catch is CancellationError {
            return
        } catch {
            withAnimation(.snappy(duration: 0.25)) {
                messages.removeAll { $0.id == temporary.id }
            }
            if replyDraft.isEmpty { replyDraft = draft }
            errorMessage = error.localizedDescription
        }
    }

    func observeIncoming() async {
        for await message in service.incomingMessages {
            withAnimation(.snappy(duration: 0.25)) {
                messages.append(message)
            }
        }
    }
}
