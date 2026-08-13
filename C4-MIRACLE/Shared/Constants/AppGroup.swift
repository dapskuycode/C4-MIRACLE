//
//  AppGroup.swift
//  C4-MIRACLE
//
//  Shared — Constants
//

import Foundation
import ManagedSettings

/// Identifiers shared by the app and all four extensions.
///
/// Every value here must match exactly across targets. The App Group is the only channel
/// the five processes have: an extension cannot call into the app, and the app cannot call
/// into an extension.
enum AppGroup {

    /// ⚠️ Must exist in the Developer Portal and be enabled on all five targets.
    /// Change this in one place only — see `Docs/SCREENTIME-SETUP.md`.
    /// If switching Apple Developer accounts, update this to match the new App Group
    /// shown in Signing & Capabilities → App Groups for the main target.
    static let identifier = "group.com.daffa.miracle"

    /// The app's own URL scheme, used for deep links from the Live Activity.
    /// Must match `CFBundleURLSchemes` in the app's Info.plist.
    static let urlScheme = "miracle"

    /// Whether this process can reach the shared container at all.
    ///
    /// Worth checking explicitly: when the App Group is missing from a target's
    /// *provisioning profile* — as opposed to its entitlements file — `UserDefaults(suiteName:)`
    /// can still hand back a usable object whose writes never reach the other processes.
    /// Nothing throws, nothing logs, and the data silently goes nowhere.
    static var isShared: Bool {
        UserDefaults(suiteName: identifier) != nil
    }

    static var defaults: UserDefaults {
        guard let defaults = UserDefaults(suiteName: identifier) else {
            NSLog("[Miracle] App Group \(identifier) unavailable — check this target's provisioning profile.")
            return .standard
        }
        return defaults
    }
}

/// A *named* `ManagedSettingsStore`. The name must be identical in the app, the shield
/// action extension and the monitor extension — otherwise each process reads and writes a
/// different, unrelated set of restrictions.
extension ManagedSettingsStore.Name {
    static let miracle = Self("MiracleStore")
}
