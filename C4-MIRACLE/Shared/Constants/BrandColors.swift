//
//  BrandColors.swift
//  C4-MIRACLE
//
//  Shared — Constants
//

import SwiftUI
import UIKit

/// The handful of colours the break flow needs.
///
/// This is **not** the Design System — that belongs in `Core/DesignSystem/` once the team
/// defines it. These live in `Shared/` out of necessity: the block screen is drawn by the
/// shield extension in UIKit, the break screen by the app in SwiftUI, and the two must not
/// drift apart. One definition, two accessors.
enum BrandColors {

    // ⚠️ Sampled by eye from the design mockup. Replace with the exact values from the
    // design file — these are a starting point, not a decision.
    private static let accentHex: UInt32 = 0x25B6A6
    /// Bottom scrim on the home screen — "Rectangle 3" in the design, a 300pt gradient from
    /// this colour at 0% alpha down to full.
    private static let homeScrimHex: UInt32 = 0x005952
    /// The water at the very bottom of the home artwork, recovered from a render by undoing
    /// the scrim it sits under. Starting the backdrop here keeps the artwork's edge from
    /// showing as a hard line.
    private static let homeWaterHex: UInt32 = 0x84D2CC
    private static let inkHex: UInt32 = 0x111111
    private static let mutedHex: UInt32 = 0x6E6E73
    private static let surfaceHex: UInt32 = 0xF2F2F7

    // MARK: - UIKit (the shield extension can only use these)

    enum UI {
        static let accent = UIColor(brandHex: accentHex)
        static let onAccent = UIColor.white
        static let ink = UIColor(brandHex: inkHex)
        static let muted = UIColor(brandHex: mutedHex)
        /// The block screen is drawn over another app, so it needs its own opaque ground.
        static let shieldBackground = UIColor.white.withAlphaComponent(0.94)
    }

    // MARK: - SwiftUI

    static let accent = Color(UI.accent)
    static let onAccent = Color(UI.onAccent)
    static let ink = Color(UI.ink)
    static let muted = Color(UI.muted)
    static let homeScrim = Color(UIColor(brandHex: homeScrimHex))
    static let homeWater = Color(UIColor(brandHex: homeWaterHex))
    static let surface = Color(UIColor(brandHex: surfaceHex))
}

private extension UIColor {
    convenience init(brandHex hex: UInt32) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255,
            blue:  CGFloat(hex & 0x0000FF) / 255,
            alpha: 1
        )
    }
}
