import Observation

@Observable
final class ToolbarErrorBanner {
    private(set) var message: String?
    private(set) var isPresented = false
    private(set) var isVisible = false
    private(set) var isPulsing = false
    private(set) var areSideItemsPresented = true
    private(set) var areSideItemsVisible = true

    private var dismissTask: Task<Void, Never>?

    func show(message: String) {
        self.message = message
        dismissTask?.cancel()
        areSideItemsVisible = false
        isPresented = true
        isVisible = false

        Task {
            try? await Task.sleep(for: .milliseconds(50))
            guard !Task.isCancelled else { return }
            areSideItemsPresented = false
            isVisible = true
            pulse()
        }

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await hide()
        }
    }

    func reset() {
        dismissTask?.cancel()
        message = nil
        isVisible = false
        isPresented = false
        areSideItemsPresented = true
        areSideItemsVisible = true
    }

    private func pulse() {
        isPulsing = true
        Task {
            try? await Task.sleep(for: .milliseconds(180))
            isPulsing = false
        }
    }

    private func hide() async {
        isVisible = false

        try? await Task.sleep(for: .milliseconds(180))
        guard !Task.isCancelled else { return }

        message = nil
        isPresented = false
        areSideItemsPresented = true

        try? await Task.sleep(for: .milliseconds(50))
        guard !Task.isCancelled else { return }

        areSideItemsVisible = true
    }
}
