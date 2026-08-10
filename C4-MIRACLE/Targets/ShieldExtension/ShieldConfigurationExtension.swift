//
//  ShieldConfigurationExtension.swift
//  C4-MIRACLE — ShieldConfiguration target
//

import UIKit
import ManagedSettings
import ManagedSettingsUI

/// Restyles the system block screen.
///
/// **What we CAN control:** icon, title, subtitle, background colour and blur, and two button
/// labels.
///
/// **What we CANNOT do:** show SwiftUI, a free-text field, or any view of our own. The shield
/// is drawn by the system in its own process. So a duration picker and a context note have to
/// live in the app, which is precisely why getting the user *into* the app is the hard part of
/// this problem.
///
/// The second job of this class is to snapshot what only this process can see. Outside a
/// shield extension, `Application.localizedDisplayName` and `.bundleIdentifier` are nil by
/// design.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        shield(for: capture(application))
    }

    override func configuration(shielding application: Application,
                                in category: ActivityCategory) -> ShieldConfiguration {
        shield(for: capture(application))
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        shield(for: webDomain.domain ?? "this site")
    }

    override func configuration(shielding webDomain: WebDomain,
                                in category: ActivityCategory) -> ShieldConfiguration {
        shield(for: webDomain.domain ?? "this site")
    }

    // MARK: -

    /// Records what only this process can see.
    ///
    /// ⚠️ `Application.token` is Optional and comes back **nil** here, so the token→name map
    /// can never be populated from this extension — which is why the shield action extension
    /// used to fall back to the literal string "an app". The name and bundle identifier *are*
    /// populated, so we record those unconditionally as the most recently shielded app, and
    /// the action extension reads that instead.
    private func capture(_ application: Application) -> String {
        let name = application.localizedDisplayName ?? "this app"

        SharedStore.lastShieldedApp = ShieldedAppInfo(
            name: name,
            bundleID: application.bundleIdentifier
        )

        // Kept for the case where iOS does hand us a token.
        if let token = application.token, let key = TokenBox.key(for: token) {
            SharedStore.recordTokenInfo(key: key, name: name, bundleID: application.bundleIdentifier)
        }

        SharedStore.log(
            "ShieldConfiguration",
            "Shield shown for \"\(name)\" (bundleID: \(application.bundleIdentifier ?? "nil"), token: \(application.token == nil ? "nil" : "present"))"
        )
        return name
    }

    // MARK: - Icon

    /// The fishing artwork.
    ///
    /// It has to be in **this extension's** asset catalog, not the app's: this process draws
    /// the shield and cannot read the app's resources. `Targets/ShieldExtension/Assets/
    /// Media.xcassets/ShieldIcon` is a copy of `Assets.xcassets/Image/Character/Fishing` —
    /// if the illustration changes, both copies have to change.
    ///
    /// An animated GIF will not work. `ShieldConfiguration` is a value the system renders once
    /// into its own UI; there is no view of ours running, no timer, and iOS caches the
    /// rendered result. Static artwork is the whole of what the API offers.
    private static let shieldIcon: UIImage? = {
        guard let custom = UIImage(named: "ShieldIcon") else {
            return UIImage(systemName: "sailboat.fill")
        }
        return custom.scaledToFit(maxDimension: 120)
    }()

    /// Deliberately **one** design, with no state-dependent branches.
    ///
    /// A "break's over" variant was tried in the proof of concept and removed: iOS caches the
    /// rendered shield, so it kept showing the original text after the flag changed, while
    /// ShieldAction acted on the new value. The two disagreed and the button misbehaved.
    /// Anything that has to change in response to state belongs in the Live Activity.
    ///
    /// The design's two stacked headings cannot both be rendered — the shield offers exactly
    /// one title and one subtitle — so the copy is the pair that carries the decision.
    /// `name` is unused for the same reason: the subtitle is fixed text by design.
    private func shield(for name: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialLight,
            backgroundColor: BrandColors.UI.shieldBackground,
            icon: Self.shieldIcon,
            title: ShieldConfiguration.Label(text: "Taking a break?", color: BrandColors.UI.ink),
            subtitle: ShieldConfiguration.Label(
                text: "Set your time and decide\nwhat's next",
                color: BrandColors.UI.muted
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Take a Break",
                color: BrandColors.UI.onAccent
            ),
            primaryButtonBackgroundColor: BrandColors.UI.accent
        )
    }
}

private extension UIImage {

    /// The shield draws its icon at roughly 100pt. A full-resolution asset handed over
    /// unscaled renders oversized and crops badly, so anything larger is fitted first.
    func scaledToFit(maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > maxDimension, longestSide > 0 else { return self }

        let ratio = maxDimension / longestSide
        let target = CGSize(width: size.width * ratio, height: size.height * ratio)

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        return UIGraphicsImageRenderer(size: target, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
    }
}
