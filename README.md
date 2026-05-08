# WMS

A mini warehouse management app built with SwiftUI. The current implementation focuses on a warehouse picking flow: an operator receives a task, sees the current item, scans a numeric label code, moves to the next item, and finishes the task.

Picking is the first implemented module. The project is designed to grow into a larger warehouse app with additional modules such as Receiving, Putaway, Inventory, and other warehouse operations.

## Project Status

In development. The Picking module is implemented; Receiving, Putaway, Inventory, and other warehouse modules are planned.

## Screenshots

Screenshots and a short demo GIF are planned:

- Operations menu
- Picking task screen
- Scanner and error state
- Task finish screen

## Features

- Warehouse operations menu: Picking, Receiving, Inventory.
- Picking flow: fetch task, current item, scan, progress, finish screen.
- AVFoundation scanner with camera preview embedded in SwiftUI.
- Scan area limited to the visible camera preview.
- Ultra wide camera selection when available, with fallback to the regular camera.
- Navigation with `NavigationStack(path:)`.
- `@Observable` ViewModel.
- Mock service for fetching and finishing picking tasks.
- Animated error banner in the navigation bar.
- System sound feedback for successful and failed scans.
- Circular picking progress indicator in the navigation bar.
- Mock items with images, storage locations, articles, and item attributes.

## Main Flow

1. Open the Picking module.
2. Fetch a picking task.
3. Check the item, label ID, and storage location.
4. Hold the camera area to scan.
5. If the scanned code matches the current item, the app moves to the next item.
6. After all items are collected, the finish screen opens.
7. Finish the task through the mock service.

## Tech Stack

- Swift
- SwiftUI
- MVVM
- Observation (`@Observable`)
- AVFoundation
- NavigationStack
- AsyncImage
- AudioToolbox
- Mock service layer

## Project Structure

```text
WMS/
├── Models/
├── Resources/
├── Screens/
│   ├── OperationsList/
│   └── Features/
│       ├── Picking/
│       ├── Receiving/
│       ├── Inventory/
│       └── Shared/
└── Services/
```

Key files:

- `PickingModuleView.swift` - Picking module entry point and task fetching.
- `PickingTaskView.swift` - Current item screen and scanner UI.
- `PickingTaskViewModel.swift` - Picking logic and code validation.
- `ScannerPreviewView.swift` - SwiftUI wrapper around the AVFoundation scanner.
- `PickingFinishView.swift` - Task completion screen.
- `PickingTaskService.swift` - Service protocol and mock implementation.

## How to Run

1. Open `WMS.xcodeproj` in Xcode.
2. Select an iPhone simulator or a physical device.
3. Use a physical iPhone to test the scanner, because the simulator does not provide a real camera.
4. Run the `WMS` target.

Minimum iOS version: iOS 17.

## Demo Notes

- The mock service includes a test user ID for checking the task fetching error state.
- Receiving, Putaway, Inventory, and other warehouse operations are planned as future modules.

## Future Improvements

- Expand test coverage for picking business logic and scanner-related edge cases.
- Add an explicit empty task state.
- Add a camera switcher for 0.5x / 1x camera modes.
- Add UI handling for denied/restricted camera permissions.
