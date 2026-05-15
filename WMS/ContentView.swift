import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OperationsListView()
                .tint(nil)
                .tabItem {
                    Label("Операции", systemImage: "shippingbox")
                }

            ProfileView()
                .tint(nil)
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
