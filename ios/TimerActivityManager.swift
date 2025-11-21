// TimerActivityManager.swift
import Foundation
import ActivityKit

@available(iOS 16.1, *)
final class TimerActivityManager {
    static let shared = TimerActivityManager()

    private var activity: Activity<TimerAttributes>?

    /// Start a new countdown Live Activity
    func start(title: String, durationSeconds: TimeInterval) async throws {
        let attributes = TimerAttributes(title: title)
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(durationSeconds)

        let state = TimerAttributes.ContentState(
            startDate: startDate,
            isRunning: true
        )

        let content = ActivityContent(
            state: state,
            staleDate: endDate
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
