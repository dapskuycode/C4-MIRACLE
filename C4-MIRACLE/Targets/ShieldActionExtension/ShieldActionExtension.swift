//
//  ShieldActionExtension.swift
//  C4-MIRACLE — ShieldAction target
//

import Foundation
import FamilyControls
import ManagedSettings

/// Handles taps on the shield's buttons.
///
/// ## The limitation that used to live here, and no longer does
///
/// Until recently a `ShieldActionDelegate` could not open its own containing app. There is no
/// `UIApplication` here and no `NSExtensionContext`, and Apple engineers said on the developer
/// forums across 2023–2025 that no supported mechanism existed. That single gap is why apps in
/// this category historically routed through a user-built Shortcuts automation.
///
/// **iOS 26.5 added `ShieldActionResponse.openParentalControlsApp`, which closes the gap.**
/// C4-MIRACLE's deployment target is 26.5, so this takes that path unconditionally and ships
/// no automation flow at all.
///
/// ## One route out of the shield
///
/// The primary button opens the app, where the duration and context note are collected.
/// Reopening the blocked app afterwards needs its identity — see `resolveIdentity`, the one
/// part of this flow that depends on iOS being willing to name the app.
class ShieldActionExtension: ShieldActionDelegate {

    override func handle(action: ShieldAction,
                         for application: ApplicationToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {

        let key = TokenBox.key(for: application)
        let identity = resolveIdentity(token: application, key: key)

        // A shield being tapped means no break is running, so any leftover countdown is stale.
        // This is often the first process to run after one expires.
        if SharedStore.activeGrant == nil {
            LiveActivityService.end(from: "ShieldAction")
        }

        switch action {
        case .primaryButtonPressed:
            // The primary button always means the same thing.
            //
            // It used to branch on `SharedStore.breakEnded` so the shield could offer "Start
            // Work" after a break expired. That desynchronised badly: iOS caches the rendered
            // shield, so ShieldConfiguration kept drawing "Take a break" while this extension
            // read the newer flag and ran the "Start Work" branch — the button said one thing
            // and did another, closing the shield and dropping the user on the Home Screen.
            //
            // A shield whose appearance cannot be refreshed must not have state-dependent
            // behaviour. The break-is-over choice lives in the Live Activity instead, which
            // does update.
            SharedStore.breakEnded = nil
            SharedStore.pendingRequest = BreakRequest(
                appName: identity.name,
                appTokenKey: key,
                appBundleID: identity.bundleID,
                source: .screenTimeShield
            )
            SharedStore.log("ShieldAction", "\"\(identity.name)\" — opening C4-MIRACLE directly (openParentalControlsApp).")
            completionHandler(.openParentalControlsApp)

        default:
            // Includes the secondary button and the submenu cases the shield never presents.
            SharedStore.log("ShieldAction", "Dismissed shield for \"\(identity.name)\".")
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction,
                         for webDomain: WebDomainToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }

    override func handle(action: ShieldAction,
                         for category: ActivityCategoryToken,
                         completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }

    // MARK: - Working out which app this actually is

    /// Three sources, cheapest and most universal first. Each attempt is logged with the source
    /// that won, so the Diagnostics timeline shows which one is doing the work on a given
    /// device instead of leaving it to guesswork.
    ///
    /// 1. `Application(token:)` — costs nothing, needs no permission. Documented as nil
    ///    *outside* an extension; this is inside one, so it is worth asking. If it populates,
    ///    no catalogue is needed at all.
    /// 2. The token map, filled by the app from `FamilyActivityData`.
    /// 3. Whatever the shield configuration extension last recorded — same second, but only if
    ///    iOS actually re-ran that extension rather than serving a cached shield.
    /// 4. Give up; the app shows an unlinked warning rather than reopening the wrong thing.
    private func resolveIdentity(token: ApplicationToken,
                                 key: String?) -> (name: String, bundleID: String?) {

        let direct = Application(token: token)
        if let name = direct.localizedDisplayName {
            SharedStore.log("ShieldAction", "Identified \"\(name)\" via Application(token:) — no linking needed.")
            if let key {
                SharedStore.recordTokenInfo(key: key, name: name, bundleID: direct.bundleIdentifier)
            }
            return (name, direct.bundleIdentifier)
        }

        if let info = SharedStore.info(forTokenKey: key) {
            SharedStore.log("ShieldAction", "Identified \"\(info.name)\" via token map (FamilyActivityData).")
            return (info.name, info.bundleID)
        }

        if let last = SharedStore.lastShieldedApp {
            SharedStore.log("ShieldAction", "Identified \"\(last.name)\" via last shielded app record.")
            return (last.name, last.bundleID)
        }

        SharedStore.log("ShieldAction", "Could NOT identify the app — Application(token:) gave nil, token map empty, no shield record.")
        return ("an app", nil)
    }
}
