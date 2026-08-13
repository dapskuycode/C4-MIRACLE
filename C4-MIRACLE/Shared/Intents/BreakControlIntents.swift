//
//  BreakControlIntents.swift
//  C4-MIRACLE
//
//  Shared — Intents
//

import AppIntents
import ActivityKit
import Foundation
import FamilyControls
import ManagedSettings

/// Buttons for the Live Activity.
///
/// ⚠️ Read before adding anything here. `Shared/` is compiled into more than one target, so an
/// `AppIntent` defined in this folder exists more than once — as
/// `MiracleLiveActivity.SomeIntent` *and* `C4_MIRACLE.SomeIntent`. An intent with
/// `openAppWhenRun = true` hands execution to the app process, which then looks for a type
/// that does not match, and the button does nothing at all with no error.
///
/// **Anything that must reach the app uses a deep link, not an intent.** Only intents that run
/// entirely inside the widget process belong here.

/// Hides the countdown without touching the break.
///
/// Runs entirely inside the Live Activity extension: ending an activity needs nothing beyond
/// ActivityKit, so no extra entitlement and no app launch.
struct DismissBreakActivityIntent: LiveActivityIntent {

    static var title: LocalizedStringResource = "Dismiss"
    static var description = IntentDescription("Hides the break countdown. The break keeps running.")
    static var openAppWhenRun: Bool = false
    static var isDiscoverable: Bool = false

    /// Explicitly `@MainActor`. The project builds with
    /// `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so `SharedStore` and `LiveActivityService`
    /// are main-actor isolated — but an `AppIntent`'s `perform()` witness is nonisolated, so
    /// without this the calls below are a Swift 6 error waiting to happen.
    @MainActor
    func perform() async throws -> some IntentResult {
        SharedStore.log("LiveActivity", "Countdown dismissed by the user.")
        SharedStore.isWorkModeActive = false
        SharedStore.clearActiveGrant(outcome: .expired)
        await LiveActivityService.endImmediately(from: "LiveActivity")
        LocalNotificationService.sendDismissNotification()
        return .result()
    }
}

/// Resumes work mode, exits social media, opens Redire app, and re-blocks distracting apps.
struct ContinueToWorkIntent: LiveActivityIntent {

    static var title: LocalizedStringResource = "Continue to work"
    static var description = IntentDescription("Resumes work mode, opens Redire app, and re-blocks distracting apps.")
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult {
        SharedStore.log("LiveActivity", "Continue to work tapped by user.")
        SharedStore.isWorkModeActive = true
        SharedStore.breakEnded = nil
        SharedStore.clearActiveGrant(outcome: .returnedToWork)
        await LiveActivityService.endImmediately(from: "LiveActivity")
        LocalNotificationService.sendContinueToWorkNotification()
        return .result()
    }
}
