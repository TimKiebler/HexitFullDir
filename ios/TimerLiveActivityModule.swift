// TimerLiveActivityModule.swift
import Foundation
import ActivityKit

@objc(TimerLiveActivityModule)
class TimerLiveActivityModule: NSObject {

    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc(start:durationSeconds:)
    func start(title: String, durationSeconds: NSNumber) {
        guard #available(iOS 16.1, *) else { return }

        let duration = durationSeconds.doubleValue

        Task {
            do {
                try await TimerActivityManager.shared.start(
                    title: title,
                    durationSeconds: duration
                )
            } catch {
                NSLog("Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
    }

    @objc
    func stop() {
        guard #available(iOS 16.1, *) else { return }

        Task {
            await TimerActivityManager.shared.stop()
        }
    }
}
