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

    /// The shield's icon is a plain `UIImage?`, so any artwork works — drop a PNG or PDF named
    /// `ShieldIcon` into `Assets/Media.xcassets` **in this extension's target**. It has to be
    /// in the extension's own bundle, not the app's: this process draws the shield, and it
    /// cannot read the app's resources.
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
    private func shield(for name: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor.black.withAlphaComponent(0.55),
            icon: Self.shieldIcon,
            title: ShieldConfiguration.Label(text: "C4-MIRACLE", color: .white),
            subtitle: ShieldConfiguration.Label(
                text: "Work Mode is on.\nYou're trying to open \(name).",
                color: UIColor.white.withAlphaComponent(0.85)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Take a break", color: .black),
            primaryButtonBackgroundColor: .white
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
