import Foundation

protocol PickingTaskServiceProtocol: AnyObject {
    func fetchTask(userId: Int) async throws -> PickingTask
}

final class PickingListServiceMock: PickingTaskServiceProtocol {
    
    private let mockItems: [Item] = [
        Item(id: 1000017, barcode: "4607043980028", article: "THRM-8821", brand: nil, title: "Термокружка", size: "350мл", color: "Чёрный", imageUrl: URL(string: "https://s.a-5.ru/i/file/161/7/f2/32/f2327ecacc88862f.jpg")!, placement: "АЛ21.05.03.12.03"),
        Item(id: 1000003, barcode: "4607043980014", article: "JNS-4453", brand: "Zara", title: "Джинсы", size: "32", color: "Синий", imageUrl: URL(string: "https://main-cdn.sbermegamarket.ru/big1/hlr-system/-13/847/668/404/231/38/100051616967b0.jpg")!, placement: "АЛ21.05.03.27.01"),
        Item(id: 1000008, barcode: "4607043980019", article: "CAP-3301", brand: "Reebok", title: "Кепка", size: nil, color: "Чёрный", imageUrl: URL(string: "https://hatsandcaps.ru/components/com_jshopping/files/img_products/full_56-045-09(0).jpg")!, placement: "АЛ21.05.03.45.02"),
        Item(id: 1000020, barcode: "4607043980031", article: "MPAD-7734", brand: nil, title: "Коврик для мыши", size: nil, color: "Чёрный", imageUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdbHmxNfPDfJzz5i5FKN8nkfmJZN3-fXjpAA&s")!, placement: "АЛ21.05.03.58.01"),
        Item(id: 1000001, barcode: "4607043980012", article: "SNK-9920", brand: "Nike", title: "Кроссовки", size: "42", color: "Белый", imageUrl: URL(string: "https://static.rendez-vous.ru/files/catalog_models/resize_640x630/3/3462742_kedy_nike_dm0211_belyy_natural_naya_kozha.JPG")!, placement: "АЛ21.05.03.63.04"),
        Item(id: 1000018, barcode: "4607043980029", article: "ORG-5512", brand: "Ikea", title: "Органайзер", size: nil, color: "Белый", imageUrl: URL(string: "https://ir.ozone.ru/s3/multimedia-1-w/c1000/7087702532.jpg")!, placement: "АЛ21.05.03.74.02"),
        Item(id: 1000006, barcode: "4607043980017", article: "SHRT-2287", brand: "Puma", title: "Шорты", size: "M", color: "Красный", imageUrl: URL(string: "https://static.insales-cdn.com/images/products/1/5761/2379585153/705752-01_1.webp")!, placement: "АЛ21.05.03.81.03"),
        Item(id: 1000016, barcode: "4607043980027", article: "PNC-2046", brand: "Kite", title: "Пенал", size: nil, color: "Синий", imageUrl: URL(string: "https://akvarel.com/storage/products/2025_06_02/products_other_528160_1_1748856353.2669.webp")!, placement: "АЛ21.05.03.95.01"),
        Item(id: 1000009, barcode: "4607043980020", article: "SWT-6643", brand: "Uniqlo", title: "Свитер", size: "L", color: "Бежевый", imageUrl: URL(string: "https://main-cdn.sbermegamarket.ru/big1/hlr-system/-78/705/966/823/192/7/100047646246b0.jpg")!, placement: "АЛ21.05.03.108.02"),
        Item(id: 1000002, barcode: "4607043980013", article: "TSH-1134", brand: "Adidas", title: "Футболка", size: "L", color: "Чёрный", imageUrl: URL(string: "https://fridaywear.ru/upload/dev2fun.imagecompress/webp/resize_cache/iblock/7f6/676_1352_1/7f64bb09cb21b36f177e86e6d7ba0423.webp")!, placement: "АЛ21.05.03.119.01"),
        Item(id: 1000007, barcode: "4607043980018", article: "SHRT-8820", brand: "Levi's", title: "Рубашка", size: "S", color: "Голубой", imageUrl: URL(string: "https://media.partner.frgroup.kz/images/3d/50/da4c7c9999a35b20c8fa29c2c0c6.jpg")!, placement: "АЛ21.05.03.133.04"),
        Item(id: 1000019, barcode: "4607043980030", article: "PWR-3309", brand: "Xiaomi", title: "Повербанк", size: "10000мАч", color: "Серый", imageUrl: URL(string: "https://avatars.mds.yandex.net/get-mpic/5219318/img_id6508126417426035281.png/orig")!, placement: "АЛ21.05.03.147.02"),
        Item(id: 1000005, barcode: "4607043980016", article: "SCK-4471", brand: nil, title: "Носки", size: "40-42", color: "Белый", imageUrl: URL(string: "https://static.markformelle.ru/site/master/catalog/536149/desktop/card/6625115.webp")!, placement: "АЛ21.05.03.162.01"),
        Item(id: 1000004, barcode: "4607043980015", article: "JKT-7756", brand: "H&M", title: "Куртка", size: "XL", color: "Серый", imageUrl: URL(string: "https://ir.ozone.ru/s3/multimedia-1-y/c1000/7286834086.jpg")!, placement: "АЛ21.05.03.178.03"),
    ]
        
    func fetchTask(userId: Int) async throws -> PickingTask {
        try await Task.sleep(for: .seconds(0.5))
        
        if userId == 666 {
            throw NSError(domain: "PickingTask", code: 666, userInfo: [
                NSLocalizedDescriptionKey: "Задание недоступно для данного пользователя"
            ])
        }
        
        return PickingTask(allItems: mockItems)

    }
    
}
