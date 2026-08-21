import SwiftUI

enum OnboardingPages {
    enum Picking {
        static let pages: [OnboardingPage] = [
            .init(
                image: .goToPlace,
                text: "Пройдите к ячейке, указанной на экране"
            ),
            .init(
                image: .checkItemId,
                text: "Найдите вещь с нужным штрих-кодом"
            ),
            .init(
                image: .checkIsItemRight,
                text: "Проверьте соответствие характеристик товара"
            ),
            .init(image: .scanItem, text: "Отсканируйте штрих-код"),
            .init(
                image: .collectOtherItems,
                text: "Таким же образом соберите оставшиеся предметы"
            ),
            .init(
                image: .scanFinishPlace,
                text: "Пройдите к точке сброса вещей, отсканируйте QR места"
            ),
            .init(
                image: .scanFinishContainer,
                text: "Отсканируйте контейнер"
            ),
            .init(
                image: .placeItemsInContainer,
                text: "Сложите вещи в контейнер"
            ),
        ]
    }
}
