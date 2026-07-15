import Foundation
import Observation

@Observable
final class TariffsViewModel {
    private let service: TariffsServiceProtocol

    private(set) var tariffs: [OperationTariff] = []
    var isLoading = false
    var errorMessage: String?

    var sections: [TariffZoneSection] {
        makeSections(from: tariffs)
    }

    init(service: TariffsServiceProtocol) {
        self.service = service
    }

    func loadTariffs() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            tariffs = try await service.getTariffs()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func makeSections(from tariffs: [OperationTariff]) -> [TariffZoneSection] {
        Dictionary(grouping: tariffs, by: \.zone)
            .map { zone, tariffs in
                TariffZoneSection(
                    zone: zone,
                    tariffs: tariffs.sorted { $0.operation < $1.operation }
                )
            }
            .sorted { $0.zone < $1.zone }
    }
}
