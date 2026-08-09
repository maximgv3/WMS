import SwiftUI

// Temporary screen: shows the task is over and drops back to the module.
// Sending the result through finishTask is still to be written.
struct PutawayFinishView: View {
    @Binding private var path: [OperationType.WorkRoute]

    init(path: Binding<[OperationType.WorkRoute]>) {
        self._path = path
    }

    var body: some View {
        content
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden(true)
    }

    private var content: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72, weight: .semibold))
                    .foregroundStyle(ColorPalette.accentPrimary)

                Text("Задание выполнено")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(ColorPalette.brandPrimary)

                Text("Можно брать следующее")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(ColorPalette.brandMuted)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton("Отлично") {
                path.removeAll()
            }
            .padding(.horizontal, 64)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.backgroundPrimary)
    }
}

#Preview {
    @Previewable @State var path: [OperationType.WorkRoute] = []

    NavigationStack(path: $path) {
        PutawayFinishView(path: $path)
    }
}
