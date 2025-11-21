// TimerWidgetBundle.swift
import WidgetKit
import SwiftUI

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Your existing static widget
        TimerWidget()

        // Live Activity
        if #available(iOSApplicationExtension 16.1, *) {
            TimerWidgetLiveActivity()
        }
    }
}
