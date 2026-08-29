import Foundation

nonisolated struct ReturnsContainer: Decodable, Sendable, Hashable {
    static let codePrefix = "WMSCT"

    let id: String
    let location: String

    static func isContainerCode(_ code: String) -> Bool {
        code.hasPrefix(codePrefix)
    }
}
