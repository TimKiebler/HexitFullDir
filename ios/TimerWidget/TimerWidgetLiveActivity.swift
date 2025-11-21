// TimerWidgetLiveActivity.swift
import ActivityKit
import WidgetKit
import SwiftUI
import UIKit

@available(iOSApplicationExtension 16.1, *)
struct TimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            TimerLiveActivityView(
                context: context,
                showsTitle: false
            )
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    TimerLiveActivityView(
                        context: context,
                        showsTitle: true
                    )
                }
            } compactLeading: {
                TimerIconView(size: 30)
            } compactTrailing: {
                Text(context.state.startDate, style: .timer)
                    .font(.system(.caption2, design: .monospaced))
                    .monospacedDigit()
            } minimal: {
                TimerIconView(size: 24)
            }
        }
    }
}

private struct TimerLiveActivityView: View {
    let context: ActivityViewContext<TimerAttributes>
    let showsTitle: Bool

    var body: some View {
        HStack(spacing: 18) {
            TimerIconView()

            Spacer(minLength: 0)

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
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 23 / 255, green: 24 / 255, blue: 27 / 255))
        )
        .containerBackground(.clear, for: .widget)
        .padding(.horizontal, 6)
    }
}

private struct TimerIconView: View {
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size / 3, style: .continuous)
                .fill(Color.white.opacity(0.08))

            iconGraphic
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var iconGraphic: some View {
        if let uiImage = UIImage(
            named: "HexStoneFrontal",
            in: .timerWidgetBundle,
            with: nil
        ) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .padding(6)
        } else {
            Image(systemName: "hexagon.fill")
                .font(.system(size: size / 2, weight: .semibold))
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
