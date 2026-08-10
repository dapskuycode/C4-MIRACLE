//
//  BreakControlIntents.swift
//  C4-MIRACLE
//
//  Shared — Intents
//

import AppIntents
import Foundation

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
struct DismissBreakActivityIntent: AppIntent {

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
        LiveActivityService.end(from: "LiveActivity")
        return .result()
    }
}
