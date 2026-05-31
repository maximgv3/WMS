# WMS

A mini warehouse management app built with SwiftUI. The current implementation focuses on a warehouse picking flow: an operator receives a task, reviews a short onboarding flow, sees the current item, scans a numeric label code, handles missing or replacement items, moves to the next item, and finishes the task.

Picking is the first implemented module. The app also includes a Profile tab with asynchronously loaded mock data and is designed to grow into a larger warehouse app with additional modules such as Receiving, Putaway, Inventory, and other warehouse operations.

## Project Status

In development. The Picking module is the most complete part of the app; Receiving, Putaway, Inventory, and other warehouse modules are planned.

## Screenshots

Screenshots and a short demo GIF are planned:

- Operations menu and profile tab
- Picking onboarding flow
- Picking task screen
- Scanner and error state
- Task finish screen

## Features

- Warehouse operations menu: Picking, Receiving, Inventory.
- Tab-based app shell with Operations and Profile sections.
- Picking flow: fetch task, onboarding, current item, scan, progress, finish screen.
- One-time illustrated Picking onboarding stored with `@AppStorage`, with replay from the task menu.
- AVFoundation scanner with camera preview embedded in SwiftUI.
- Scan area limited to the visible camera preview.
- Ultra wide camera selection when available, with fallback to the regular camera.
- Navigation with `NavigationStack(path:)`.
- `@Observable` ViewModel.
- Mock service for fetching, validating replacements, and finishing picking tasks.
- Animated error banner in the navigation bar.
- System sound feedback for successful and failed scans.
- Circular picking progress indicator in the navigation bar.
- Missing item flow with confirmation and skipped item summary.
- Replacement item mode for collecting an allowed analog item.
- Manual demo controls for testing successful and failed collection without the camera.
- Profile screen with AsyncImage avatar, finance cards, detail rows, async mock loading, loading/error states, and pull-to-refresh.
- Mock items with images, storage locations, articles, stock values, prices, and item attributes.
- Swift Testing coverage for core picking ViewModel/result behavior and Profile ViewModel loading states.

## Main Flow

1. Open the Picking module.
2. Fetch a picking task.
3. Complete the Picking onboarding on first launch, or replay it from the task menu.
4. Check the item, label ID, and storage location.
5. Hold the camera area to scan.
6. If the scanned code matches the current item, the app moves to the next item.
7. If the item is missing, confirm the skip and continue.
8. If an allowed analog item is found, use replacement mode to collect it.
9. After all items are collected or skipped, the finish screen opens.
10. Finish the task through the mock service.

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
- Swift Testing

## Project Structure

```text
WMS/
├── Models/
├── Resources/
├── Screens/
│   ├── OperationsList/
│   ├── Profile/
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
- `PickingOnboardingView.swift` - Illustrated onboarding for the Picking flow.
- `PickingProgressMenu.swift` - Navigation bar progress indicator and progress details menu.
- `PickingTaskViewModel.swift` - Picking logic and code validation.
- `ScannerPreviewView.swift` - SwiftUI wrapper around the AVFoundation scanner.
- `PickingFinishView.swift` - Task completion screen.
- `PickingResult.swift` - Summary model for collected, skipped, and replacement items.
- `PickingTaskService.swift` - Service protocol and mock implementation.
- `Profile.swift` - Profile data model.
- `ProfileView.swift` - Profile tab UI.
- `ProfileViewModel.swift` - Profile loading state and refresh logic.
- `ProfileService.swift` - Profile service protocol and mock implementation.
- `PickingTaskViewModelTests.swift` - Swift Testing tests for Picking logic.
- `ProfileViewModelTests.swift` - Swift Testing tests for Profile loading behavior.

## How to Run

1. Open `WMS.xcodeproj` in Xcode.
2. Select an iPhone simulator or a physical device.
3. Use a physical iPhone to test the scanner, because the simulator does not provide a real camera.
4. Run the `WMS` target.

Minimum iOS version: iOS 17.

## Demo Notes

- The mock service includes a test user ID for checking the task fetching error state.
- Picking onboarding completion is stored locally with `@AppStorage`.
- The task menu includes demo controls and an onboarding replay action for local testing.
- Receiving, Putaway, Inventory, and other warehouse operations are planned as future modules.

## Future Improvements

- Expand test coverage for scanner-related edge cases and navigation flows.
- Add an explicit empty task state.
- Add a camera switcher for 0.5x / 1x camera modes.
- Add UI handling for denied/restricted camera permissions.
- Decode mock Profile data from JSON to better simulate an API response.
- Add detail screens for Profile menu items.
