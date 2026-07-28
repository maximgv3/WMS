import SwiftUI

struct SupportView: View {

    @State private var viewModel: SupportViewModel

    init(service: SupportServiceProtocol) {
        self.viewModel = SupportViewModel(service: service)
    }

    var body: some View {
        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()
            content
        }
        .safeAreaInset(edge: .bottom) {
            replyBar
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .navigationTitle("Поддержка")
        .navigationBarTitleDisplayMode(.inline)
        .errorBanner(title: "Ошибка", message: $viewModel.errorMessage)
        .task {
            await viewModel.loadMessages()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.messages.isEmpty {
            ProgressView()
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
        }
    }

    private func send() {
        Task { await viewModel.send() }
    }

    private var replyBar: some View {
        HStack(spacing: 12) {
            TextField("Сообщение...", text: $viewModel.replyDraft)
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
            .disabled(viewModel.replyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .glassIfAvailable()
    }
}

#Preview {
    NavigationStack{
        SupportView(service: SupportServiceMock())
    }
}
