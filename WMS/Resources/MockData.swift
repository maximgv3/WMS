import Foundation

struct MockData {
    static let itemsMock: [Item] = {
        do {
            return try MockJSONLoader.decode(PickingTask.self, from: "picking_task").allItems
        } catch {
            return []
        }
    }()

    static let profileMock: Profile = Profile(
        name: "Гвазава Максим Александрович",
        imageUrl: URL(
            string:
                "https://sun9-1.userapi.com/s/v1/ig2/oNxDkf_sAkoTnFVCU3gjLTbvgc-7Luo-lyR5FUTw_fkBoaen9C0Xb7-Th1Q4LL45vPH99A_nQFMPx8nLlE6V_dO5.jpg?quality=95&as=32x43,48x64,72x96,108x144,160x213,240x320,360x480,480x640,540x720,640x853,720x960,1080x1440,1280x1707,1440x1920,1920x2560&from=bu&u=lxaomKbnmjX0juMyksVX_k_G5PuVDWboDWSd7FDbhy0&cs=1920x0"
        )!,
        pendingFundsKopecks: 5000_00,
        balanceFundsKopecks: 10000_00,
        rating: 27
    )
    
    static let ratingHistory: [RatingPoint] = {
        let values: [Double] = [
            4.9, 17.2, 18.0, 18.4, 19.1, 19.6, 20.0, 20.3, 19.9, 20.5,
            21.0, 21.3, 21.1, 18.6, 15.0, 16.8, 23.2, 25.4, 22.1, 22.6,
            22.3, 22.7, 22.5, 22.9, 22.6, 23.0, 22.8, 22.4, 22.7, 22.56
        ]
        let today = Calendar.current.startOfDay(for: .now)
        return values.enumerated().map { index, value in
            let daysAgo = values.count - 1 - index
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!
            return RatingPoint(date: date, value: value)
        }
    }()
    
    static let operationsRatings: [OperationRating] = [
        .init(name: "Сборка",         value: 24.20, iconName: "cart",                  didGoUp: true),
        .init(name: "Приёмка",        value: 11.43, iconName: "tray.and.arrow.down",   didGoUp: false),
        .init(name: "Инвент",         value: 0.00,  iconName: "checklist",             didGoUp: nil),
        .init(name: "Упаковка",       value: 8.10,  iconName: "archivebox",            didGoUp: true),
        .init(name: "Раскладка",      value: 5.32,  iconName: "square.grid.3x3",       didGoUp: true),
        .init(name: "Обмеры",          value: 3.14,  iconName: "ruler",                 didGoUp: false),
        .init(name: "Сортировка",     value: 1.20,  iconName: "arrow.up.arrow.down",   didGoUp: nil),
        .init(name: "Брак",           value: 0.00,  iconName: "exclamationmark.triangle", didGoUp: nil)
    ]

    static let operationTariffs: [OperationTariff] = [
        .init(operation: "Сборка",    zone: "Блок 1", rateKopecks: 1250),
        .init(operation: "Приёмка",   zone: "Блок 1", rateKopecks: 980),
        .init(operation: "Раскладка", zone: "Блок 1", rateKopecks: 740),
        .init(operation: "Упаковка",  zone: "Блок 1", rateKopecks: 620),

        .init(operation: "Сборка",    zone: "Блок 2", rateKopecks: 1400),
        .init(operation: "Приёмка",   zone: "Блок 2", rateKopecks: 1120),
        .init(operation: "Раскладка", zone: "Блок 2", rateKopecks: 860),
        .init(operation: "Упаковка",  zone: "Блок 2", rateKopecks: 700),

        .init(operation: "Сборка",    zone: "Блок 3", rateKopecks: 1650),
        .init(operation: "Приёмка",   zone: "Блок 3", rateKopecks: 1300),
        .init(operation: "Раскладка", zone: "Блок 3", rateKopecks: 1010),
        .init(operation: "Упаковка",  zone: "Блок 3", rateKopecks: 840),

        .init(operation: "Сборка",    zone: "Блок 4", rateKopecks: 1800),
        .init(operation: "Приёмка",   zone: "Блок 4", rateKopecks: 1450),
        .init(operation: "Раскладка", zone: "Блок 4", rateKopecks: 1150),
        .init(operation: "Упаковка",  zone: "Блок 4", rateKopecks: 960),

        .init(operation: "Сборка",    zone: "Блок 5", rateKopecks: 1950),
        .init(operation: "Приёмка",   zone: "Блок 5", rateKopecks: 1580),
        .init(operation: "Раскладка", zone: "Блок 5", rateKopecks: 1260),
        .init(operation: "Упаковка",  zone: "Блок 5", rateKopecks: 1080)
    ]
}
