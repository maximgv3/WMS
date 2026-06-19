import Foundation
import Observation

@Observable
final class ProfileFinanceViewModel {
    private let service: ProfileFinanceServiceProtocol

    var summary: ProfileFinanceSummary?
    var isLoading = false
    var errorMessage: String?

    init(service: ProfileFinanceServiceProtocol) {
        self.service = service
    }

    func loadFinances() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            summary = try await service.getFinanceSummary()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
