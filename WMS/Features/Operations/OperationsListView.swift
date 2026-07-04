import SwiftUI

struct OperationsListView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    private let operations: [OperationMenuItem] = [
        .init(operation: .picking, isEnabled: true),
        .init(operation: .receiving, isEnabled: false),
        .init(operation: .inventory, isEnabled: false)
    ]
    @State private var selectedOperation: OperationType?
    private let cameraPermissionService = CameraPermissionService()
    @State private var cameraBlockReason: CameraAccessBlockReason?

    var body: some View {
        NavigationStack {
            ZStack {
                ColorPalette.brandPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    customTopBar

                    operationsList
                        .background(ColorPalette.surfacePrimary)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 28,
                                topTrailingRadius: 28
                            )
                        )
                        .ignoresSafeArea(edges: .bottom)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(item: $selectedOperation) { operation in
                destination(for: operation)
                    .interactiveDismissDisabled()
            }
        }
        .onAppear {
            guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return } // disable blocker for canvas work
            cameraBlockReason = cameraPermissionService.blockReason()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
            cameraBlockReason = cameraPermissionService.blockReason()
        }
        .fullScreenCover(item: $cameraBlockReason) { reason in
            CameraAccessBlockedView(
                blockReason: reason,
                onAccessGranted: {
                    cameraBlockReason = nil
                },
                onAccessDenied: {
                    cameraBlockReason = .denied
                },
                permissionService: cameraPermissionService
            )
            .interactiveDismissDisabled()
        }
    }

    private var customTopBar: some View {
        HStack {
            Text("Операции")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(ColorPalette.brandPrimary)
    }

    private var operationsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(operations.enumerated()), id: \.element.id) {
                    index,
                    item in
                    let operation = item.operation
                    Button {
                        selectedOperation = operation
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        ColorPalette.accentPrimary.opacity(0.18)
                                    )
                                    .frame(width: 44, height: 44)

                                Image(systemName: operation.iconName)
                                    .foregroundStyle(ColorPalette.brandPrimary)
                                    .font(.system(size: 22))
                            }

                            Text(operation.title)
                                .foregroundStyle(ColorPalette.brandPrimary)
                                .font(.system(size: 17, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWeight(.medium)

                            Image(systemName: item.isEnabled ? "chevron.right" : "lock")
                                .foregroundStyle(
                                    ColorPalette.brandMuted.opacity(0.75)
                                )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!item.isEnabled)

                    if index < operations.count - 1 {
                        Divider()
                            .padding(.leading, 64)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .scrollDisabled(true)
    }

    @ViewBuilder
    private func destination(for operation: OperationType) -> some View {
        switch operation {
        case .picking:
            PickingModuleView()
        case .receiving:
            ReceivingModuleView()
        case .inventory:
            InventoryModuleView()
        }
    }
}

#Preview {
    OperationsListView()
}
