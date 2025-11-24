// TimerWidgetLiveActivity.swift
import ActivityKit
import WidgetKit
import SwiftUI
import UIKit

@available(iOSApplicationExtension 16.1, *)
struct TimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // Lock screen / banner
            TimerLiveActivityView(
                context: context,
                showsTitle: false
            )
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    // Expanded Dynamic Island
                    TimerLiveActivityView(
                        context: context,
                        showsTitle: true
                    )
                }
            } compactLeading: {
                // Small icon in compact island
                TimerIconView(size: 24)
            } compactTrailing: {
                // Timer on the right in compact island
                Text(context.state.startDate, style: .timer)
                    .font(.system(.caption2, design: .monospaced))
                    .monospacedDigit()
            } minimal: {
                TimerIconView(size: 20)
            }
        }
    }
}

private struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerAttributes>
    let showsTitle: Bool

    var body: some View {
        HStack(spacing: 16) {
            // BIG icon on the far left
            TimerIconView(size: 56)

            Spacer(minLength: 0)

            // Timer (and optional title) on the far right
            VStack(alignment: .trailing, spacing: showsTitle ? 2 : 0) {
                if showsTitle {
                    Text(context.attributes.title)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Text(context.state.startDate, style: .timer)
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
        }
        // Let it stretch edge-to-edge inside the system’s Live Activity container
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        // Use the system Live Activity background; no extra inner “card”
        .containerBackground(.clear, for: .widget)
    }
}

private struct TimerIconView: View {
    var size: CGFloat = 44

    var body: some View {
        // Just the icon, no extra rounded background around it
        iconGraphic
            .frame(width: size, height: size)
    }

    @ViewBuilder
    private var iconGraphic: some View {
        if let uiImage = UIImage(
            named: "HexStoneFrontalMinimal",
            in: .timerWidgetBundle,
            with: nil
        ) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            // Fallback SF Symbol
            Image(systemName: "hexagon.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

private final class TimerWidgetBundleMarker: NSObject {}

private extension Bundle {
    static let timerWidgetBundle: Bundle = {
        Bundle(for: TimerWidgetBundleMarker.self)
    }()
}
