//
//  LiveActivityService.swift
//  C4-MIRACLE
//
//  Shared — Services
//

import Foundation
import ActivityKit

/// Starts and ends the break countdown in the Dynamic Island.
///
/// Lives in `Shared` rather than `Core` because **ending** has to be attempted from more than
/// one process. ActivityKit only allows *starting* an activity from a foregrounded app, but
/// ending one is permitted elsewhere — and the break usually runs out while the user is in
/// Instagram, with the app nowhere near the foreground.
enum LiveActivityService {

    @discardableResult
    static func start(grant: BreakGrant) async -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            SharedStore.log("App", "Live Activities are disabled in Settings — skipping Dynamic Island.")
            return false
        }

        // Only one break runs at a time. Await the end properly — the old fire-and-forget
        // Task could complete *after* the new activity was created and silently kill it.
        let existing = Activity<BreakActivityAttributes>.activities
        for activity in existing {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        if !existing.isEmpty {
            SharedStore.log("App", "Ended \(existing.count) old Live Activity before starting new one.")
        }

        let attributes = BreakActivityAttributes(appName: grant.appName)
        let state = BreakActivityAttributes.ContentState(
            startedAt: grant.grantedAt,
            endsAt: grant.expiresAt,
            nextTask: grant.nextTask
        )

        do {
            // `staleDate` is not cosmetic here: it is the only thing that flips the Live
            // Activity into its "break's over" look at the right moment. ActivityKit marks the
            // content stale on its own and the widget re-renders locally, with no process
            // running and nothing pushed.
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: grant.expiresAt),
                pushType: nil
            )
            SharedStore.log("App", "Live Activity started — \(grant.appName), ends \(grant.expiresAt).")
            return true
        } catch {
            SharedStore.log("App", "Live Activity request FAILED: \(error)")
            return false
        }
    }

    /// Triggers 1st auto-expansion when 1 minute remains without changing design.
    static func alertWarning1MinLeft() {
        guard let activity = Activity<BreakActivityAttributes>.activities.first else { return }
        let state = activity.content.state
        guard !state.isOver else { return }

        Task {
            await activity.update(
                ActivityContent(state: state, staleDate: activity.content.staleDate),
                alertConfiguration: AlertConfiguration(
                    title: "1 minute left",
                    body: "Your break is almost over. Get ready to return!",
                    sound: .default
                )
            )
            SharedStore.log("App", "Live Activity 1-min warning alert sent (1st auto-expand).")
        }
    }

    /// Flips the countdown into its "over" state and alerts.
    ///
    /// `alertConfiguration` is the only supported way to make the Dynamic Island present
    /// itself — an app cannot expand it on demand. The activity is kept alive on purpose so
    /// the two buttons stay reachable.
    ///
    /// Best effort only, and specifically a no-op when called from `DeviceActivityMonitor`:
    /// `Activity.activities` lists only activities owned by the calling process, and an
    /// extension owns none.
    static func markOver(appName: String) {
        guard let activity = Activity<BreakActivityAttributes>.activities.first else { return }
        var state = activity.content.state
        guard !state.isOver else { return }
        state.isOver = true

        Task {
            // As per recipe instructions: use staleDate: Date().addingTimeInterval(60)
            // to ensure the system doesn't immediately ignore the updated state.
            await activity.update(
                ActivityContent(state: state, staleDate: Date().addingTimeInterval(60)),
                alertConfiguration: AlertConfiguration(
                    title: "Break's over",
                    body: "It's time to do \(state.nextTask)!",
                    sound: .default
                )
            )
            SharedStore.log("App", "Live Activity switched to \"break's over\" with an alert to auto-expand.")
        }
    }

    /// Removes the countdown entirely.
    @discardableResult
    static func end(from process: String = "App") -> Bool {
        let activities = Activity<BreakActivityAttributes>.activities
        guard !activities.isEmpty else {
            SharedStore.log(process, "No Live Activity visible from this process — cannot end it here.")
            return false
        }
        Task {
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            SharedStore.log(process, "Live Activity ended and dismissed.")
        }
        return true
    }

    /// Synchronously awaits removal of all live activities (ideal for AppIntents).
    static func endImmediately(from process: String = "App") async {
        let activities = Activity<BreakActivityAttributes>.activities
        guard !activities.isEmpty else {
            SharedStore.log(process, "No Live Activity visible to end immediately.")
            return
        }
        for activity in activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        SharedStore.log(process, "Live Activity ended immediately.")
    }
}
