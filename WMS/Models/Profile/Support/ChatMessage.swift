import Foundation

nonisolated struct ChatMessage: Codable, Identifiable, Sendable {
    let date: Date
    let fromUser: Bool
    let text: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, text
        case fromUser = "from_user"
    }
}
