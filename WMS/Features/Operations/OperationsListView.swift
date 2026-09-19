import SwiftUI

struct OperationsListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ActiveTaskStore.self) private var activeTaskStore

    private let operations: [OperationMenuItem] = [
        .init(operation: .putaway, isEnabled: true),
        .init(operation: .picking, isEnabled: true),
        .init(operation: .returns, isEnabled: true),
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
                    ModuleHeader(title: .operationsTitle)

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
            .fullScreenCover(
                item: $selectedOperation,
                onDismiss: activeTaskStore.refresh
            ) { operation in
                OperationModuleView(
                    operationType: operation,
                    activeTaskStore: activeTaskStore
                )
                .interactiveDismissDisabled()
            }
        }
        .onAppear {
            guard
                ProcessInfo.processInfo.environment[
                    "XCODE_RUNNING_FOR_PREVIEWS"
                ] != "1"
            else { return }  // disable blocker for canvas work
            cameraBlockReason = cameraPermissionService.blockReason()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            guard
                ProcessInfo.processInfo.environment[
                    "XCODE_RUNNING_FOR_PREVIEWS"
                ] != "1"
            else { return }
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
                            IconChip(systemName: operation.iconName, size: 44)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(operation.title)
                                    .foregroundStyle(ColorPalette.textPrimary)
                                    .font(.system(size: 17, weight: .medium))

                                if activeTaskStore.activeOperation == operation {
                                    Text(.operationsContinueTask)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(ColorPalette.success)
                                        .shimmer()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Image(
                                systemName: isOperationEnabled(item)
                                    ? "chevron.right" : "lock"
                            )
                            .foregroundStyle(
                                ColorPalette.brandMuted.opacity(0.75)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!isOperationEnabled(item))
                    .opacity(isOperationEnabled(item) ? 1 : 0.5)

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

    private func isOperationEnabled(_ item: OperationMenuItem) -> Bool {
        let activeOperation = activeTaskStore.activeOperation
        return item.isEnabled
            && (activeOperation == nil || activeOperation == item.operation)
    }
}

#Preview {
    OperationsListView()
        .environment(ActiveTaskStore())
}
