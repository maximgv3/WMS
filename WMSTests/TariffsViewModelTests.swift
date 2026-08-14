import Foundation
import Testing

@testable import WMS

@MainActor
struct TariffsViewModelTests {

    @Test
    func sectionsGroupTariffsByZone() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 1"),
            makeTariff(operation: "Раскладка", zone: "Блок 1"),
            makeTariff(operation: "Сборка", zone: "Блок 2"),
        ])
        await viewModel.loadTariffs()

        #expect(viewModel.sections.count == 2)
        #expect(viewModel.sections.first?.tariffs.count == 2)
        #expect(viewModel.sections.last?.tariffs.count == 1)
    }

    @Test
    func sectionsSortZonesNaturally() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 10"),
            makeTariff(operation: "Сборка", zone: "Блок 2"),
            makeTariff(operation: "Сборка", zone: "Блок 1"),
        ])
        await viewModel.loadTariffs()

        // Plain sorting would put "Блок 10" before "Блок 2"
        #expect(viewModel.sections.map(\.zone) == ["Блок 1", "Блок 2", "Блок 10"])
    }

    @Test
    func sectionsSortTariffsByOperationInsideZone() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 1"),
            makeTariff(operation: "Раскладка", zone: "Блок 1"),
        ])
        await viewModel.loadTariffs()

        #expect(
            viewModel.sections.first?.tariffs.map(\.operation)
                == ["Раскладка", "Сборка"]
        )
    }

    @Test
    func allZonesAreUniqueAndSortedNaturally() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 10"),
            makeTariff(operation: "Раскладка", zone: "Блок 10"),
            makeTariff(operation: "Сборка", zone: "Блок 2"),
        ])
        await viewModel.loadTariffs()

        #expect(viewModel.allZones == ["Блок 2", "Блок 10"])
    }

    @Test
    func zoneFilterKeepsOnlySelectedZone() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 1"),
            makeTariff(operation: "Сборка", zone: "Блок 2"),
        ])
        await viewModel.loadTariffs()

        viewModel.toggleZone("Блок 2")

        #expect(viewModel.sections.map(\.zone) == ["Блок 2"])
        #expect(viewModel.hasActiveFilters)
    }

    @Test
    func operationFilterKeepsOnlySelectedOperation() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 1"),
            makeTariff(operation: "Раскладка", zone: "Блок 1"),
        ])
        await viewModel.loadTariffs()

        viewModel.toggleOperation("Раскладка")

        #expect(viewModel.sections.count == 1)
        #expect(
            viewModel.sections.first?.tariffs.map(\.operation) == ["Раскладка"]
        )
    }

    @Test
    func zoneAndOperationFiltersApplyTogether() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 1"),
            makeTariff(operation: "Раскладка", zone: "Блок 1"),
            makeTariff(operation: "Раскладка", zone: "Блок 2"),
        ])
        await viewModel.loadTariffs()

        viewModel.toggleZone("Блок 1")
        viewModel.toggleOperation("Раскладка")

        #expect(viewModel.sections.map(\.zone) == ["Блок 1"])
        #expect(
            viewModel.sections.first?.tariffs.map(\.operation) == ["Раскладка"]
        )
    }

    @Test
    func resetFiltersBringsAllSectionsBack() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 1"),
            makeTariff(operation: "Сборка", zone: "Блок 2"),
        ])
        await viewModel.loadTariffs()

        viewModel.toggleZone("Блок 1")
        viewModel.resetFilters()

        #expect(viewModel.hasActiveFilters == false)
        #expect(viewModel.sections.count == 2)
    }

    @Test
    func togglingSameZoneTwiceRemovesTheFilter() async {
        let viewModel = makeViewModel(tariffs: [
            makeTariff(operation: "Сборка", zone: "Блок 1"),
            makeTariff(operation: "Сборка", zone: "Блок 2"),
        ])
        await viewModel.loadTariffs()

        viewModel.toggleZone("Блок 1")
        viewModel.toggleZone("Блок 1")

        #expect(viewModel.hasActiveFilters == false)
        #expect(viewModel.sections.count == 2)
    }

    private func makeTariff(
        operation: String,
        zone: String,
        rateKopecks: Int = 1000
    ) -> OperationTariff {
        OperationTariff(
            operation: operation,
            zone: zone,
            rateKopecks: rateKopecks
        )
    }

    private func makeViewModel(tariffs: [OperationTariff]) -> TariffsViewModel {
        TariffsViewModel(service: TariffsServiceMock(tariffs: tariffs))
    }
}
