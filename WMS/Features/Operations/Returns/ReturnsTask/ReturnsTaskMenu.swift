import SwiftUI

struct ReturnsTaskMenu: View {
    let isAllItemsChecked: Bool
    let onFinishEarly: () -> Void
    let onFinish: () -> Void
    let onDemoModeChanged: () -> Void
    let onTutorial: () -> Void
    let onExit: () -> Void

    @State private var isEarlyFinishPresented = false

    #if DEBUG
        @AppStorage("isReturnsDemoModeOn") private var isDemoModeOn = false
        @State private var isDemoConfirmationPresented = false
    #endif

    var body: some View {
        Menu {
            if !isAllItemsChecked {
                Button {
                    onFinishEarly()
                    isEarlyFinishPresented = true
                } label: {
                    Label(
                        .commonFinishEarlyAction,
                        systemImage: "flag.checkered"
                    )
                }
            }

            #if DEBUG
                Button {
                    demoButtonTapped()
                } label: {
                    Label(
                        .commonDemoMode,
                        systemImage:
                            "arrow.trianglehead.2.clockwise.rotate.90.camera"
                    )
                }
            #endif

            Button {
                onTutorial()
            } label: {
                Label(
                    .commonViewTutorial,
                    systemImage: "book.closed"
                )
            }

            Button(role: .destructive) {
                onExit()
            } label: {
                Label(
                    .commonExitOperation,
                    systemImage: "rectangle.portrait.and.arrow.right"
                )
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(ColorPalette.textPrimary)
        }
        .confirmationDialog(
            .commonEarlyFinishTitle,
            isPresented: $isEarlyFinishPresented,
            titleVisibility: .visible
        ) {
            Button(.commonFinish, role: .destructive) {
                onFinish()
            }
        } message: {
            Text(
                .returnsEarlyFinishWarning
            )
        }
        #if DEBUG
            .confirmationDialog(
                .commonDemoMode,
                isPresented: $isDemoConfirmationPresented,
                titleVisibility: .visible
            ) {
                Button(.commonEnable) {
                    demoModeToggle()
                }
            } message: {
                Text(
                    .returnsTaskDemoModeDescription
                )
            }
        #endif
    }

    #if DEBUG
        private func demoButtonTapped() {
            if isDemoModeOn {
                demoModeToggle()
            } else {
                isDemoConfirmationPresented = true
            }
        }

        private func demoModeToggle() {
            isDemoModeOn.toggle()
            onDemoModeChanged()
        }
    #endif
}
