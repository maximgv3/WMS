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
}
