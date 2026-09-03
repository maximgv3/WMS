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

    enum Putaway {
        static let pages: [OnboardingPage] = [
            .init(
                image: .scanContainer,
                text: "Найдите нужный контейнер и отсканируйте его"
            ),
            .init(
                image: .placeItemsInCart,
                text: "Переложите товары из контейнера в тележку"
            ),
            .init(
                image: .scanPlace,
                text: "Выберите любую свободную ячейку и отсканируйте её"
            ),
            .init(
                image: .scanItemInCell,
                text: "Отсканируйте товар и положите его в ячейку"
            ),
            .init(
                image: .changeCell,
                text: "Когда место в ячейке закончилось, смените её"
            ),
            .init(
                image: .finishTask,
                text: "Разложите таким образом все товары и завершите задание"
            ),
            .init(
                image: .returnEmptyContainer,
                text: "Откатите пустой контейнер в зону хранения"
            ),
        ]
    }

    enum Returns {
        static let pages: [OnboardingPage] = [
            .init(
                image: .scanReturnsContainer,
                text: "Найдите тару с возвратами и отсканируйте её код"
            ),
            .init(
                image: .scanResultContainers,
                text:
                    "Отсканируйте тары: для годного товара и для товара на проверку"
            ),
            .init(
                image: .scanReturnItem,
                text: "Достаньте товар из тары и отсканируйте его штрих-код"
            ),
            .init(
                image: .checkReturnItem,
                text: "Осмотрите товар: тот ли это товар и нет ли повреждений"
            ),
            .init(
                image: .chooseDecision,
                text: "Выберите решение: годен, брак или подмена"
            ),
            .init(
                image: .photographItem,
                text: "При браке или подмене сфотографируйте проблему"
            ),
            .init(
                image: .placeItemInResultContainer,
                text: "Положите товар в тару, соответствующую решению"
            ),
            .init(
                image: .finishReturnsTask,
                text: "Проверьте так все товары и завершите задание"
            ),
        ]
    }
}
