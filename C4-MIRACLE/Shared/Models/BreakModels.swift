//
//  BreakModels.swift
//  C4-MIRACLE
//
//  Shared — Models
//

import Foundation

/// Which mechanism produced the intervention.
///
/// This matters because the paths carry different amounts of information: the shield gives
/// us an opaque token that must be looked up, while a manual request carries a plain name.
enum InterventionSource: String, Codable {
    case screenTimeShield
    case manual

    var displayName: String {
        switch self {
        case .screenTimeShield: return "Screen Time shield"
        case .manual:           return "Manual (in-app test)"
        }
    }
}

/// Written by whichever process intercepted the user; read by the main app.
struct BreakRequest: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var appName: String
    /// Base64 of the encoded `ApplicationToken`, when we have one. Never a bundle ID —
    /// iOS does not expose bundle IDs outside the shield configuration extension.
    var appTokenKey: String? = nil
    /// Only the shield configuration extension can see this. Far more reliable than matching
    /// on a display name, which is localised and user-visible.
    var appBundleID: String? = nil
    var source: InterventionSource
    var requestedAt: Date = Date()
}

/// How a break came to an end. Recorded when the grant is archived, because that is the only
/// moment all three outcomes are distinguishable — afterwards the grant is gone.
enum BreakOutcome: String, Codable {
    /// The user chose to go back to work while the break was still running.
    case returnedToWork
    /// The user ended the break early from inside the app.
    case endedEarly
    /// The break ran out on its own and the user never came back to close it.
    case expired

    /// Whether the user closed the loop themselves.
    var isCommitted: Bool { self != .expired }
}

/// Written when the user confirms a break. This is the record that unlocks the apps.
struct BreakGrant: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var appName: String
    var appTokenKey: String?
    var appBundleID: String?
    var durationSeconds: Int
    /// What the user plans to do once the break is over. Written on the break screen.
    var nextTask: String
    var grantedAt: Date
    var expiresAt: Date
    /// Set only when the grant is archived into the history.
    var outcome: BreakOutcome?

    var isActive: Bool { Date() < expiresAt }
    var remaining: TimeInterval { max(0, expiresAt.timeIntervalSinceNow) }

    init(request: BreakRequest, durationSeconds: Int, nextTask: String, now: Date = Date()) {
        self.appName = request.appName
        self.appTokenKey = request.appTokenKey
        self.appBundleID = request.appBundleID
        self.durationSeconds = durationSeconds
        self.nextTask = nextTask
        self.grantedAt = now
        self.expiresAt = now.addingTimeInterval(TimeInterval(durationSeconds))
    }
}

/// Appended by every process so Diagnostics can show, on one timeline, what each of the five
/// processes actually did. Extensions cannot be debugged any other way.
struct LogEvent: Codable, Identifiable {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var process: String
    var message: String
}

/// What the shield configuration extension saw, recorded unconditionally.
///
/// The token→name map alone is not enough: `Application.token` comes back nil inside that
/// extension, so the map can never be populated from there. `bundleIdentifier` and
/// `localizedDisplayName` *are* populated, so we record those and let the shield action
/// extension read the most recent entry.
struct ShieldedAppInfo: Codable, Equatable {
    var name: String
    var bundleID: String?
    var seenAt: Date = Date()
}

/// Recorded the moment a break runs out, so the next surface can react to it.
struct BreakEndedInfo: Codable, Equatable {
    var appName: String
    var durationSeconds: Int
    var endedAt: Date = Date()
}
