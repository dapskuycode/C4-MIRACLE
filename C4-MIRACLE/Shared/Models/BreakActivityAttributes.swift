//
//  BreakActivityAttributes.swift
//  C4-MIRACLE
//
//  Shared — Models
//

import Foundation
import ActivityKit

/// The Live Activity shown in the Dynamic Island and on the Lock Screen while a break runs.
///
/// Shared between the app (which starts and ends the activity) and the Live Activity
/// extension (which renders it). They are separate processes, so this type has to be
/// byte-identical in both — hence its place in `Shared`.
struct BreakActivityAttributes: ActivityAttributes {

    /// Fixed for the lifetime of the activity.
    var appName: String

    /// The part that changes. `endsAt` drives a self-updating countdown: SwiftUI's
    /// `Text(timerInterval:)` ticks on its own, so the activity needs neither pushes nor a
    /// background timer — which matters, because a third-party app cannot run one.
    struct ContentState: Codable, Hashable {
        var startedAt: Date
        var endsAt: Date
        var nextTask: String
        /// Once true the activity stops counting down and offers the two choices instead.
        /// It deliberately stays on screen rather than ending: this is the only surface that
        /// reliably reaches the user when a break runs out.
        var isOver: Bool = false
    }
}
