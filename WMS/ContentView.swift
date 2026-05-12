import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OperationsListView()
                .tint(ColorPalette.brandPrimary)
                .tabItem {
                    Label("Операции", systemImage: "shippingbox")
                }

            ProfileView()
                .tint(ColorPalette.brandPrimary)
                .tabItem {
                    Label("Профиль", systemImage: "person.crop.circle")
                }
        }
        .tint(ColorPalette.accentPrimary)
        .preferredColorScheme(.light)
    }
}
#Preview {
    ContentView()
}
