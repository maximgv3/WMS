import SwiftUI

struct SupportView: View {
    
    @State private var replyDraft = ""
    
    @State private var messages: [ChatMessage] = [
        .init(date: .now, fromUser: false, text: "Здравствуйте! Чем можем помочь?", id: "1"),
        .init(date: .now, fromUser: true,  text: "Не приходит подтверждение приёмки", id: "2"),
        .init(date: .now, fromUser: false, text: "Проверяю, одну минуту…", id: "3"),
    ]
    
    var body: some View {
        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
        }
        .safeAreaInset(edge: .bottom) {
            replyBar
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .navigationTitle("Поддержка")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func send() {
        let text = replyDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        withAnimation(.snappy(duration: 0.25)) {
            messages.append(
                .init(date: .now, fromUser: true, text: text, id: UUID().uuidString)
            )
        }
        replyDraft = ""
    }
    
    private var replyBar: some View {
        HStack(spacing: 12) {
            TextField("Сообщение...", text: $replyDraft)
                .textFieldStyle(.plain)
                .onSubmit(send)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            Button {
                send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(ColorPalette.brandPrimary)
                    .padding(4)
            }
            .padding(.horizontal, 8)
            .disabled(replyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .glassIfAvailable()
    }
}

#Preview {
    NavigationStack{
        SupportView()
    }
}
