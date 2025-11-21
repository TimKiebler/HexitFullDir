// TimerAttributes.swift
import ActivityKit
import Foundation

struct TimerAttributes: ActivityAttributes {

    // Dynamic state shown in the Live Activity
    public struct ContentState: Codable, Hashable {
        /// When the timer will end (for a countdown)
        var startDate: Date
        /// Just in case you later add pause/resume
        var isRunning: Bool
    }

    // Static attributes for the activity
    var title: String
}
