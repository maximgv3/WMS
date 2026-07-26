import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.fromUser {
                Spacer(minLength: 60)
            }
            
            Text(message.text)
                .foregroundStyle(message.fromUser ? ColorPalette.surfacePrimary : ColorPalette.brandPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.fromUser ? ColorPalette.brandPrimary : ColorPalette.accentPrimary.opacity(0.18),
                    in: UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: message.fromUser ? 20 : 4,
                        bottomTrailingRadius: message.fromUser ? 4 : 20,
                        topTrailingRadius: 20,
                        style: .continuous
                    )
                )
            
            if !message.fromUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    MessageBubble(message: .init(date: .now, fromUser: true, text: "Это текст от пользователя. У меня случилась такая-то проблема", id: UUID().uuidString))

    MessageBubble(message: .init(date: .now, fromUser: false, text: "Это текст от поддержки. Вашу проблему можно решить так-то так-то", id: UUID().uuidString)
    )
}
