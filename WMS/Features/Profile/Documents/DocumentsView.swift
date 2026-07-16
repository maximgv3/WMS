import SwiftUI

struct DocumentsView: View {
    @State private var viewModel: DocumentsViewModel

    init(service: DocumentsServiceProtocol) {
        self.viewModel = DocumentsViewModel(service: service)
    }

    var body: some View {
        ZStack {
            ColorPalette.brandPrimary.ignoresSafeArea()
            content
        }
        .task {
            await viewModel.loadDocuments()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.documents.isEmpty {
            ProgressView()
                .tint(ColorPalette.surfacePrimary)
        } else if let error = viewModel.errorMessage, viewModel.documents.isEmpty {
            errorState(error)
        } else if viewModel.documents.isEmpty {
            ErrorView(
                type: .other(
                    icon: "doc.text",
                    title: "Документы недоступны.\nПопробуйте позже.",
                    autoDismiss: false
                )
            )
        } else {
            loadedState
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 40) {
            Text(message)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(ColorPalette.surfacePrimary)
                .multilineTextAlignment(.center)
            PrimaryButton("Попробовать снова", variant: .capsule) {
                Task { await viewModel.loadDocuments() }
            }
        }
        .padding(.horizontal, 24)
    }

    private var loadedState: some View {
        VStack(spacing: .zero) {
            Text("Документы")
                .font(.largeTitle).bold()
                .foregroundStyle(ColorPalette.surfacePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

            ZStack(alignment: .top) {
                Color.white
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 32,
                            topTrailingRadius: 32
                        )
                    )
                    .ignoresSafeArea(edges: .bottom)
                documentsList
            }
        }
    }

    private var documentsList: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ForEach(viewModel.documents) { document in
                    NavigationLink {
                        DocumentPreviewView(
                            document: document,
                            viewModel: viewModel
                        )
                    } label: {
                        documentRow(document)
                    }
                    .buttonStyle(.plain)
                    if document.id != viewModel.documents.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }

    private func documentRow(_ document: WarehouseDocument) -> some View {
        HStack(spacing: 16) {
            IconChip(systemName: "doc.text", size: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.body)
                    .foregroundStyle(ColorPalette.brandPrimary)
                    .multilineTextAlignment(.leading)
                Text("Обновлён " + document.updatedAt.formattedAsDocumentDate())
                    .font(.system(size: 13))
                    .foregroundStyle(ColorPalette.brandMuted)
            }

            Spacer()

            if !document.isAcknowledged {
                Circle()
                    .fill(ColorPalette.accentPrimary)
                    .frame(width: 8, height: 8)
            }

            Image(systemName: "chevron.right")
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding(.vertical, 14)
        .contentShape(.rect)
    }
}

#Preview {
    NavigationStack {
        DocumentsView(service: DocumentsServiceMock())
    }
}
