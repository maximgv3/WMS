import SwiftUI

struct DocumentPreviewView: View {
    let document: WarehouseDocument
    @Bindable var viewModel: DocumentsViewModel

    var body: some View {
        ZStack {
            ColorPalette.backgroundPrimary.ignoresSafeArea()
            documentContent
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            // Signing off on a document the worker could not read would be a lie.
            if document.fileUrl != nil {
                acknowledgeBar
            }
        }
        .errorBanner(
            title: "Не удалось отметить",
            message: $viewModel.errorMessage
        )
    }

    @ViewBuilder
    private var documentContent: some View {
        if let url = document.fileUrl {
            PDFKitView(url: url)
        } else {
            ErrorView(
                type: .other(
                    icon: "doc.text",
                    title: "Файл недоступен",
                    autoDismiss: false
                )
            )
        }
    }

    @ViewBuilder
    private var acknowledgeBar: some View {
        if viewModel.isAcknowledged(document.id) {
            acknowledgedLabel
        } else {
            PrimaryButton(
                "Ознакомлен",
                isLoading: viewModel.isAcknowledging(document.id)
            ) {
                Task { await viewModel.acknowledge(document.id) }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var acknowledgedLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
            Text("Вы ознакомились с документом")
        }
        .font(.system(size: 15, weight: .medium))
        .foregroundStyle(ColorPalette.brandMuted)
        .padding(.vertical, 16)
    }
}

#Preview {
    NavigationStack {
        DocumentPreviewView(
            document: MockData.warehouseDocuments[2],
            viewModel: DocumentsViewModel(service: DocumentsServiceMock())
        )
    }
}
