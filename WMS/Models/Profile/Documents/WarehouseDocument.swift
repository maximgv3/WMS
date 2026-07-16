import Foundation

struct WarehouseDocument: Identifiable {
    var id: String { fileName }
    let title: String
    let fileName: String
    let updatedAt: Date
    var isAcknowledged: Bool

    var fileUrl: URL? {
        Bundle.main.url(forResource: fileName, withExtension: "pdf")
    }
}
