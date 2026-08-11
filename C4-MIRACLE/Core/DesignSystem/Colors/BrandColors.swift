//
//  BrandColors.swift
//  C4-MIRACLE
//
//  Shared — Constants
//

import SwiftUI
import UIKit

enum BrandColors {
    private static let accentHex: UInt32 = 0x25B6A6
    private static let homeScrimHex: UInt32 = 0x005952
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
