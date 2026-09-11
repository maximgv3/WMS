import Foundation

struct MockData {
    static let itemsMock: [Item] = {
        do {
            return try MockJSONLoader.decode(PickingTask.self, from: "picking_task").allItems
        } catch {
            return []
        }
    }()

    static let putawayTaskMock: PutawayTask = {
        do {
            return try MockJSONLoader.decode(PutawayTask.self, from: "putaway_task")
        } catch {
            return PutawayTask(items: [], cellCapacity: 0, container: PutawayContainer(id: "", location: ""))
        }
    }()

    static let returnsTaskMock: ReturnsTask = {
        do {
            return try MockJSONLoader.decode(ReturnsTask.self, from: "returns_task")
        } catch {
            return ReturnsTask(
                container: ReturnsContainer(id: "", location: ""),
                items: []
            )
        }
    }()

    static let ratingHistory: [RatingPoint] = {
        let values: [Double] = [
            4.9, 17.2, 18.0, 18.4, 19.1, 19.6, 20.0, 20.3, 19.9, 20.5,
            21.0, 21.3, 21.1, 18.6, 15.0, 16.8, 23.2, 25.4, 22.1, 22.6,
            22.3, 22.7, 22.5, 22.9, 22.6, 23.0, 22.8, 22.4, 22.7, 23.0
        ]
        let today = Calendar.current.startOfDay(for: .now)
        return values.enumerated().map { index, value in
            let daysAgo = values.count - 1 - index
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!
            return RatingPoint(date: date, value: value)
        }
    }()
    
    static let operationsRatings: [OperationRating] = [
        .init(name: localized(.operationsPicking), value: 24.20, iconName: "cart", didGoUp: true),
        .init(name: localized(.commonReceiving), value: 11.43, iconName: "tray.and.arrow.down", didGoUp: false),
        .init(name: localized(.commonInventory), value: 0.00, iconName: "checklist", didGoUp: nil),
        .init(name: localized(.commonPacking), value: 8.10, iconName: "archivebox", didGoUp: true),
        .init(name: localized(.operationsPutaway), value: 5.32, iconName: "square.grid.3x3", didGoUp: true),
        .init(name: localized(.commonReturns), value: 7.46, iconName: "shippingbox.and.arrow.backward", didGoUp: true),
        .init(name: localized(.commonMeasurements), value: 3.14, iconName: "ruler", didGoUp: false),
        .init(name: localized(.commonSorting), value: 1.20, iconName: "arrow.up.arrow.down", didGoUp: nil),
        .init(name: localized(.returnsDefective), value: 0.00, iconName: "exclamationmark.triangle", didGoUp: nil)
    ]

    static let operationTariffs: [OperationTariff] = {
        let operations = [
            localized(.operationsPicking),
            localized(.operationsReturnsInspection),
            localized(.commonReceiving),
            localized(.operationsPutaway),
            localized(.commonPacking),
        ]
        let rates = [
            [1250, 1100, 980, 740, 620],
            [1400, 1230, 1120, 860, 700],
            [1650, 1450, 1300, 1010, 840],
            [1800, 1580, 1450, 1150, 960],
            [1950, 1710, 1580, 1260, 1080],
        ]

        return rates.enumerated().flatMap { zoneIndex, zoneRates in
            let zone = String(
                localized: .tariffsBlockNumber(zoneIndex + 1)
            )
            return zip(operations, zoneRates).map { operation, rate in
                OperationTariff(
                    operation: operation,
                    zone: zone,
                    rateKopecks: rate
                )
            }
        }
    }()

    static let warehouseDocuments: [WarehouseDocument] = {
        let today = Calendar.current.startOfDay(for: .now)
        func date(daysAgo: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!
        }
        return [
            .init(
                title: localized(.commonWorkplaceSafetyInstructions),
                fileName: "safety_instruction",
                updatedAt: date(daysAgo: 45),
                isAcknowledged: true
            ),
            .init(
                title: localized(.commonOrderPickingProcedure),
                fileName: "picking_regulations",
                updatedAt: date(daysAgo: 12),
                isAcknowledged: true
            ),
            .init(
                title: localized(.commonWarehouseOperatingHoursPolicy),
                fileName: "warehouse_order",
                updatedAt: date(daysAgo: 3),
                isAcknowledged: false
            ),
            .init(
                title: localized(.commonNewEmployeeGuide),
                fileName: "newcomer_guide",
                updatedAt: date(daysAgo: 60),
                isAcknowledged: false
            )
        ]
    }()
    
    static let firstSupportMessages: [ChatMessage] = [
        .init(date: .now - 61 * 60, fromUser: false, text: localized(.commonHelloHowCanWeHelp), id: "1"),
        .init(date: .now - 60 * 60, fromUser: true, text: localized(.supportReceivingTaskCompletionIssue), id: "2"),
        .init(date: .now - 59 * 60, fromUser: false, text: localized(.supportTaskRecordedConfirmation), id: "3"),
    ]

    static var replySupportMessages: [ChatMessage] { [
        .init(date: .now, fromUser: false, text: localized(.supportConnectingToSpecialist), id: UUID().uuidString),
        .init(date: .now, fromUser: false, text: localized(.supportHighDemandDelayNotice), id: UUID().uuidString),
        .init(date: .now, fromUser: false, text: localized(.supportContinueWorkNotice), id: UUID().uuidString),
    ] }

    private static func localized(
        _ resource: LocalizedStringResource
    ) -> String {
        String(localized: resource)
    }
}
