import SwiftUI

enum OnboardingPages {
    enum Picking {
        static let pages: [OnboardingPage] = [
            .init(
                image: .goToPlace,
                text: .onboardingGoToTheBinShownOnTheScreen
            ),
            .init(
                image: .checkItemId,
                text: .onboardingPickingFindMatchingBarcode
            ),
            .init(
                image: .checkIsItemRight,
                text: .onboardingCheckThatTheItemDetailsMatch
            ),
            .init(image: .scanItem, text: .onboardingScanTheBarcode),
            .init(
                image: .collectOtherItems,
                text: .onboardingPickingContinueRemainingItems
            ),
            .init(
                image: .scanFinishPlace,
                text: .onboardingPickingScanDropOffPoint
            ),
            .init(
                image: .scanFinishContainer,
                text: .onboardingScanTheContainer
            ),
            .init(
                image: .placeItemsInContainer,
                text: .onboardingPlaceTheItemsInTheContainer
            ),
        ]
    }

    enum Putaway {
        static let pages: [OnboardingPage] = [
            .init(
                image: .scanContainer,
                text: .onboardingPutawayScanRequiredContainer
            ),
            .init(
                image: .placeItemsInCart,
                text: .onboardingPutawayMoveItemsToCart
            ),
            .init(
                image: .scanPlace,
                text: .onboardingPutawayScanAvailableBin
            ),
            .init(
                image: .scanItemInCell,
                text: .onboardingPutawayScanItemIntoBin
            ),
            .init(
                image: .changeCell,
                text: .onboardingPutawaySwitchFullBin
            ),
            .init(
                image: .finishTask,
                text: .onboardingPutawayCompleteAllItems
            ),
            .init(
                image: .returnEmptyContainer,
                text: .onboardingPutawayReturnEmptyContainer
            ),
        ]
    }

    enum Returns {
        static let pages: [OnboardingPage] = [
            .init(
                image: .scanReturnsContainer,
                text: .onboardingReturnsScanReturnsTote
            ),
            .init(
                image: .scanResultContainers,
                text:
                    .onboardingReturnsScanDestinationTotes
            ),
            .init(
                image: .scanReturnItem,
                text: .onboardingReturnsScanItemFromTote
            ),
            .init(
                image: .checkReturnItem,
                text: .onboardingPickingVerifyItem
            ),
            .init(
                image: .chooseDecision,
                text: .onboardingReturnsChooseDecision
            ),
            .init(
                image: .photographItem,
                text: .onboardingReturnsPhotographIssue
            ),
            .init(
                image: .placeItemInResultContainer,
                text: .onboardingReturnsPlaceItemByDecision
            ),
            .init(
                image: .finishReturnsTask,
                text: .onboardingReturnsCompleteAllItems
            ),
        ]
    }
}
