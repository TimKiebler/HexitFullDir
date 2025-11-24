// TimerActivityManager.swift
import Foundation
import ActivityKit

@available(iOS 16.1, *)
final class TimerActivityManager {
    static let shared = TimerActivityManager()

    private var activity: Activity<TimerAttributes>?

    /// Start a new Live Activity that keeps running until `stop()` is called.
    /// `durationSeconds` represents the already-elapsed time on the timer so the widget
    /// picks up from the current session instead of resetting to zero.
    func start(title: String, durationSeconds: TimeInterval) async throws {
        let attributes = TimerAttributes(title: title)
        // Offset the start date backwards by the elapsed duration so the widget timer
        // displays the accumulated time immediately.
        let startDate = Date().addingTimeInterval(-durationSeconds)

        let state = TimerAttributes.ContentState(
            startDate: startDate,
            isRunning: true
        )

        let content = ActivityContent(
            state: state,
            staleDate: nil // keep the activity alive until explicitly ended
        )

        let activity = try Activity.request(
            attributes: attributes,
            content: content
        )

        self.activity = activity
    }

    /// End the Live Activity
    func stop() async {
        guard let activity else { return }

        let finalState = TimerAttributes.ContentState(
            startDate: activity.content.state.startDate,
            isRunning: false
        )

        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )

        self.activity = nil
    }
}
