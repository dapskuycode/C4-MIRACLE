//
//  BreakLiveActivity.swift
//  C4-MIRACLE — LiveActivity target
//

import SwiftUI
import WidgetKit
import ActivityKit
import AppIntents

/// The Dynamic Island + Lock Screen presentation of a running break.
///
/// The countdown uses `Text(timerInterval:)` throughout, which SwiftUI ticks by itself from
/// the end date. Nothing here polls and the app does not push updates — a third-party app
/// cannot run a background timer, so a self-driving view is the only accurate option.
///
/// The progress bar uses `ProgressView(timerInterval:countsDown:false)` with a custom
/// `ProgressViewStyle`. The system updates `fractionCompleted` automatically from the timer
/// interval, so the fish marker slides in real-time without any manual updates.
struct BreakLiveActivity: Widget {

    /// Whether the break has run out.
    private func isOver(_ context: ActivityViewContext<BreakActivityAttributes>) -> Bool {
        context.state.isOver || context.isStale || Date() >= context.state.endsAt
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BreakActivityAttributes.self) { context in
            lockScreen(context)
                .activityBackgroundTint(.black)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 0) {
                        if isOver(context) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(context.attributes.appName)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.45))
                                    Text("Time is up!")
                                        .font(.title3.bold())
                                        .foregroundStyle(.white)
                                        .padding(.top, 1)
                                }
                                Spacer()
                                HStack(spacing: 6) {
                                    Image(systemName: "fish.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(Color.gray.opacity(0.8))
                                    Image.narekPanceng
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(x: -1, y: 1)
                                        .frame(width: 32, height: 24)
                                }
                                .padding(.trailing, 8)
                            }
                            
                            if !context.state.nextTask.isEmpty {
                                Text("It's time to do \(context.state.nextTask)!")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.85))
                                    .lineLimit(1)
                                    .padding(.top, 2)
                            }
                        } else {
                            Text(context.attributes.appName)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.45))
                            
                            // Layout countdown inside the center HStack to avoid being pushed off-screen by DynamicIsland limits
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("Break Time Remaining")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Spacer(minLength: 6)
                                countdown(context, font: .subheadline.monospacedDigit().bold())
                            }
                            .padding(.top, 1)
                            
                            if !context.state.nextTask.isEmpty {
                                Text("\(context.state.nextTask) are waiting...")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.45))
                                    .lineLimit(1)
                                    .padding(.top, 1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        if isOver(context) {
                            dynamicIslandControls
                                .padding(.top, 8)
                        } else {
                            progressBar(context)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                Image.narekPanceng
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(x: -1, y: 1)
                    .frame(width: 22, height: 16)
            } compactTrailing: {
                if isOver(context) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(Color(red: 29/255, green: 100/255, blue: 104/255))
                } else {
                    countdown(context, font: .caption.monospacedDigit())
                        .frame(maxWidth: 44)
                }
            } minimal: {
                Image.narekPanceng
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(x: -1, y: 1)
                    .frame(width: 20, height: 15)
            }
            .keylineTint(Color(red: 29/255, green: 100/255, blue: 104/255))
        }
    }

    // MARK: - Progress Bar

    private func progressBar(_ context: ActivityViewContext<BreakActivityAttributes>) -> some View {
        BreakProgressBar(
            startedAt: context.state.startedAt,
            endsAt: context.state.endsAt,
            isOver: isOver(context)
        )
    }

    // MARK: - Core Layout Content

    /// Shared layout structure used for the Lock Screen (spacious).
    @ViewBuilder
    private func lockScreenContent(_ context: ActivityViewContext<BreakActivityAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if isOver(context) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(context.attributes.appName)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                        Text("Time is up!")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .padding(.top, 4)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "fish.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color.gray.opacity(0.8))
                        Image.narekPanceng
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(x: -1, y: 1)
                            .frame(width: 36, height: 26)
                    }
                    .padding(.trailing, 4)
                }

                if !context.state.nextTask.isEmpty {
                    Text("It's time to do \(context.state.nextTask)!")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }

                lockScreenControls
                    .padding(.top, 14)
            } else {
                Text(context.attributes.appName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("Break Time Remaining")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer(minLength: 6)
                    countdown(context, font: .headline.monospacedDigit().bold())
                }
                .padding(.top, 4)

                if !context.state.nextTask.isEmpty {
                    Text("\(context.state.nextTask) are waiting...")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(1)
                        .padding(.top, 2)
                }

                progressBar(context)
                    .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Lock Screen

    private func lockScreen(_ context: ActivityViewContext<BreakActivityAttributes>) -> some View {
        lockScreenContent(context)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }

    // MARK: - Controls (Lock Screen)

    @ViewBuilder
    private var lockScreenControls: some View {
        HStack(spacing: 12) {
            Button(intent: DismissBreakActivityIntent()) {
                Text("Dismiss")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 245/255, green: 80/255, blue: 100/255))
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color(red: 235/255, green: 245/255, blue: 246/255), in: Capsule())
            }
            .buttonStyle(.plain)

            Link(destination: URL(string: "miracle://startwork")!) {
                Text("Continue to work")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
        }
    }

    // MARK: - Controls (Dynamic Island - Compact)

    @ViewBuilder
    private var dynamicIslandControls: some View {
        HStack(spacing: 10) {
            Button(intent: DismissBreakActivityIntent()) {
                Text("Dismiss")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 245/255, green: 80/255, blue: 100/255))
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .background(Color(red: 235/255, green: 245/255, blue: 246/255), in: Capsule())
            }
            .buttonStyle(.plain)

            Link(destination: URL(string: "miracle://startwork")!) {
                Text("Continue to work")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .background(Color(red: 29/255, green: 100/255, blue: 104/255), in: Capsule())
            }
        }
    }

    // MARK: - Countdown

    private func countdown(_ context: ActivityViewContext<BreakActivityAttributes>,
                           font: Font) -> some View {
        Text(timerInterval: context.state.startedAt...context.state.endsAt,
             countsDown: true)
            .font(font)
            .multilineTextAlignment(.trailing)
            .foregroundStyle(Color(red: 29/255, green: 100/255, blue: 104/255))
    }
}

// MARK: - Progress Bar View

private struct BreakProgressBar: View {

    let startedAt: Date
    let endsAt:    Date
    let isOver:    Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {

            if !isOver {
                // Active: fish at the left (departure point)
                Image(systemName: "fish.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray.opacity(0.8))
            }

            // Smooth animated fill — system-rendered.
            // When timer runs out, explicitly render 100% static fill to avoid lazy iOS refresh bugs.
            Group {
                if isOver {
                    ProgressView(value: 1.0, total: 1.0)
                } else {
                    ProgressView(
                        timerInterval: startedAt...endsAt,
                        countsDown: false
                    )
                }
            }
            .tint(Color(red: 29/255, green: 100/255, blue: 104/255))
            .labelsHidden()
            .frame(maxWidth: .infinity)

            if isOver {
                // Over: fish arrived at destination!
                Image(systemName: "fish.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.gray.opacity(0.8))
            }

            // Fisherman boat destination, always at right
            Image.narekPanceng
                .resizable()
                .scaledToFit()
                .scaleEffect(x: -1, y: 1)
                .frame(width: 42, height: 28)
        }
        .frame(height: 28)
        .animation(.easeInOut(duration: 0.35), value: isOver)
    }
}
