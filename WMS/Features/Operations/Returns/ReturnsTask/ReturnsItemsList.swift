import SwiftUI

struct ReturnsItemsList: View {
    let leftItems: [ReturnItem]
    let checkedItems: [ReturnItem]
    let decisions: [Item.ID: ReturnDecision]
    let photos: [Item.ID: Image]

    private var listedItems: [ReturnItem] {
        leftItems + checkedItems
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                if !leftItems.isEmpty {
                    Text(.returnsRemainingToInspect)
                        .font(.headline)
                }

                // One ForEach for both groups keeps a row alive when it moves down
                ForEach(listedItems) { returnItem in
                    if returnItem.id == checkedItems.first?.id {
                        Text(.returnsInspected)
                            .font(.headline)
                            .padding(.top, 12)
                    }
                    ReturnsItemRow(
                        returnItem: returnItem,
                        decision: decisions[returnItem.id],
                        photo: photos[returnItem.id]
                    )
                }
            }
            .padding(.horizontal, 16)
            .animation(.snappy, value: listedItems)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, -16)
    }
}
