import SwiftUI

struct PickingFinishView: View {
    @Binding var path: [PickingRoute]
    let collectedItems: [Item]

    var body: some View {
        VStack(spacing: 16) {
            Text("Сборка завершена")
                .font(.title.bold())
            Text("Собрано товаров: \(collectedItems.count)")
                .foregroundStyle(.secondary)
            Button("Finish") {
                finish()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func finish() {
        path.removeAll()
    }
}
