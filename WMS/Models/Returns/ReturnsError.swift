import Foundation

enum ReturnsError: Error {
    case notAnItem
    case itemNotInTask
    case decisionRequired
    case wrongContainer
    case notAContainer
    case containerAlreadyUsed
}
