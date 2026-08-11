//
//  SharedStore.swift
//  C4-MIRACLE
//
//  Shared — Storage
//

import Foundation

/// The single shared surface between the app and its four extensions.
///
/// Everything here is plain `UserDefaults` in the App Group container. That is deliberate:
/// the shield extensions are short-lived, memory-constrained processes that cannot be
/// attached to a debugger, so the storage layer needs to be as boring as possible.
enum SharedStore {

    private enum Key {
        static let pendingRequest    = "pendingBreakRequest"
        static let activeGrant       = "activeBreakGrant"
        static let grantHistory      = "grantHistory"
        static let tokenNames        = "tokenAppInfoV2"
        static let workModeActive    = "workModeActive"
        static let workModeStartedAt = "workModeStartedAt"
        static let selection         = "familyActivitySelectionData"
        static let log               = "eventLog"
        static let hasOnboarded      = "hasOnboarded"
        static let lastShielded      = "lastShieldedApp"
        static let breakEnded        = "breakEndedInfo"
        static let endBreakRequested = "endBreakRequested"
        static let resumptionCue      = "resumptionCueEnabled"
    }

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    // MARK: - Pending request (written by the interceptor, read by the app)

    static var pendingRequest: BreakRequest? {
        get { read(Key.pendingRequest) }
        set { write(newValue, Key.pendingRequest) }
    }

    static func clearPendingRequest() {
        AppGroup.defaults.removeObject(forKey: Key.pendingRequest)
    }

    // MARK: - Active grant (written on Save, read by everyone)

    static var activeGrant: BreakGrant? {
        get { read(Key.activeGrant) }
        set { write(newValue, Key.activeGrant) }
    }

    /// - Parameter outcome: how the break ended, stamped onto the archived copy. The history
    ///   is what the home screen's daily recap counts, so an unstamped grant is invisible to it.
    static func clearActiveGrant(outcome: BreakOutcome? = nil) {
        if var grant = activeGrant {
            grant.outcome = outcome
            var history: [BreakGrant] = read(Key.grantHistory) ?? []
            history.insert(grant, at: 0)
            write(Array(history.prefix(20)), Key.grantHistory)
        }
        AppGroup.defaults.removeObject(forKey: Key.activeGrant)
    }

    static var grantHistory: [BreakGrant] {
        read(Key.grantHistory) ?? []
    }

    // MARK: - Token → app info map
    //
    // Populated by the **app** via FamilyActivityData, not by the shield configuration
    // extension. That extension cannot populate it: `Application.token` is Optional and comes
    // back nil there. iOS also caches shield configurations, so the extension may not run
    // again on later shields — anything depending on it is fragile.

    static var tokenInfo: [String: ShieldedAppInfo] {
        get { read(Key.tokenNames) ?? [:] }
        set { write(newValue, Key.tokenNames) }
    }

    static func recordTokenInfo(key: String, name: String, bundleID: String?) {
        var map = tokenInfo
        let existing = map[key]
        guard existing?.name != name || existing?.bundleID != bundleID else { return }
        map[key] = ShieldedAppInfo(name: name, bundleID: bundleID)
        tokenInfo = map
    }

    static func info(forTokenKey key: String?) -> ShieldedAppInfo? {
        guard let key else { return nil }
        return tokenInfo[key]
    }

    static func displayName(forTokenKey key: String?) -> String? {
        info(forTokenKey: key)?.name
    }

    // MARK: - Last shielded app
    //
    // Written by the shield configuration extension every time a shield is drawn, and read
    // moments later by the shield action extension when the user taps a button. The two are
    // separate processes, so the App Group is the only channel between them.

    static var lastShieldedApp: ShieldedAppInfo? {
        get { read(Key.lastShielded) }
        set { write(newValue, Key.lastShielded) }
    }

    // MARK: - "A break just ended"
    //
    // Set by the monitor extension when a break is used up. Cleared as soon as a new break is
    // granted, or when the user goes back to work.

    static var breakEnded: BreakEndedInfo? {
        get { read(Key.breakEnded) }
        set { write(newValue, Key.breakEnded) }
    }

    /// Set by the Live Activity's "Start Work" button; consumed by the app on next
    /// foreground. The widget extension cannot re-apply a shield itself — that needs the
    /// Family Controls entitlement — so it leaves a request instead.
    static var endBreakRequested: Bool {
        get { AppGroup.defaults.bool(forKey: Key.endBreakRequested) }
        set { AppGroup.defaults.set(newValue, forKey: Key.endBreakRequested) }
    }

    // MARK: - Notification preferences

    /// Whether to tell the user when a break has run out.
    ///
    /// Read by the app when it schedules the expiry notification *and* by the monitor
    /// extension when it posts its own — two processes, one switch, which is exactly why it
    /// lives here rather than in the app's own defaults.
    ///
    /// Defaults to on. `UserDefaults.bool` returns false for a key that was never written, so
    /// the absence of a value has to be checked explicitly or the feature would start off.
    static var isResumptionCueEnabled: Bool {
        get {
            guard AppGroup.defaults.object(forKey: Key.resumptionCue) != nil else { return true }
            return AppGroup.defaults.bool(forKey: Key.resumptionCue)
        }
        set { AppGroup.defaults.set(newValue, forKey: Key.resumptionCue) }
    }

    // MARK: - Work mode

    static var isWorkModeActive: Bool {
        get { AppGroup.defaults.bool(forKey: Key.workModeActive) }
        set {
            AppGroup.defaults.set(newValue, forKey: Key.workModeActive)
            if newValue {
                AppGroup.defaults.set(Date(), forKey: Key.workModeStartedAt)
            } else {
                AppGroup.defaults.removeObject(forKey: Key.workModeStartedAt)
            }
        }
    }

    static var workModeStartedAt: Date? {
        AppGroup.defaults.object(forKey: Key.workModeStartedAt) as? Date
    }

    // MARK: - Selected apps
    //
    // Stored as raw Data so extensions can decode a `FamilyActivitySelection` without this
    // file needing to import FamilyControls.

    static var selectionData: Data? {
        get { AppGroup.defaults.data(forKey: Key.selection) }
        set { AppGroup.defaults.set(newValue, forKey: Key.selection) }
    }

    // MARK: - Onboarding

    static var hasOnboarded: Bool {
        get { AppGroup.defaults.bool(forKey: Key.hasOnboarded) }
        set { AppGroup.defaults.set(newValue, forKey: Key.hasOnboarded) }
    }

    // MARK: - Cross-process log

    static func log(_ process: String, _ message: String) {
        var events: [LogEvent] = read(Key.log) ?? []
        events.insert(LogEvent(process: process, message: message), at: 0)
        write(Array(events.prefix(200)), Key.log)
        NSLog("[Miracle/\(process)] \(message)")
    }

    static var events: [LogEvent] {
        read(Key.log) ?? []
    }

    static func clearLog() {
        AppGroup.defaults.removeObject(forKey: Key.log)
    }

    // MARK: - Codable plumbing

    private static func read<T: Decodable>(_ key: String) -> T? {
        guard let data = AppGroup.defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    private static func write<T: Encodable>(_ value: T?, _ key: String) {
        guard let value, let data = try? encoder.encode(value) else {
            AppGroup.defaults.removeObject(forKey: key)
            return
        }
        AppGroup.defaults.set(data, forKey: key)
    }
}
