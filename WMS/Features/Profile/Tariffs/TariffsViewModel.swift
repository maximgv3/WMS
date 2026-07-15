import Foundation
import Observation

@Observable
final class TariffsViewModel {
    private let service: TariffsServiceProtocol

    private(set) var tariffs: [OperationTariff] = []
    var isLoading = false
    var errorMessage: String?

    var selectedZones: Set<String> = []
    var selectedOperations: Set<String> = []

    var allZones: [String] {
        Set(tariffs.map(\.zone)).sorted()
    }

    var allOperations: [String] {
        Set(tariffs.map(\.operation)).sorted()
    }

    var sections: [TariffZoneSection] {
        makeSections(from: filteredTariffs)
    }

    private var filteredTariffs: [OperationTariff] {
        tariffs.filter { tariff in
            (selectedZones.isEmpty || selectedZones.contains(tariff.zone))
                && (selectedOperations.isEmpty
                    || selectedOperations.contains(tariff.operation))
        }
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

    func toggleZone(_ zone: String) {
        if selectedZones.contains(zone) {
            selectedZones.remove(zone)
        } else {
            selectedZones.insert(zone)
        }
    }

    func toggleOperation(_ operation: String) {
        if selectedOperations.contains(operation) {
            selectedOperations.remove(operation)
        } else {
            selectedOperations.insert(operation)
        }
    }

    var hasActiveFilters: Bool {
        !selectedZones.isEmpty || !selectedOperations.isEmpty
    }

    func resetFilters() {
        selectedZones.removeAll()
        selectedOperations.removeAll()
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
