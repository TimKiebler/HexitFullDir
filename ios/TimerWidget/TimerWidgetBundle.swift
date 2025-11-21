//
//  TimerWidgetBundle.swift
//  TimerWidget
//
//  Created by Tim Kiebler on 20.11.25.
//

import WidgetKit
import SwiftUI

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerWidget()
        TimerWidgetControl()
        TimerWidgetLiveActivity()
    }
}
