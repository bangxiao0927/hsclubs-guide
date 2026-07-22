import SwiftUI

/// Blue palette that mirrors the hsclubs.net mini-site, with adaptive colors so
/// the app reads correctly in both light and dark mode.
enum GuideTheme {
    // MARK: Accent + text

    /// Primary accent blue (#2563eb light / #7dd3fc dark).
    static let primary = adaptive(light: 0x2563EB, dark: 0x7DD3FC)
    /// Subtle blue-tinted surface used behind primary elements.
    static let primarySoft = adaptive(light: 0xEAF1FE, dark: 0x16283F)
    /// Primary text (slate-900 / near-white).
    static let textPrimary = adaptive(light: 0x0F172A, dark: 0xF8FAFC)
    /// Muted secondary text (slate-600 / slate-300).
    static let textMuted = adaptive(light: 0x475569, dark: 0x94A3B8)

    // MARK: Surfaces

    /// Card background (#ffffff / #101b2d).
    static let cardSurface = adaptive(light: 0xFFFFFF, dark: 0x101B2D)
    /// Soft blue border used around cards and inputs.
    static let border = adaptiveColor(
        light: Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255).opacity(0.16),
        dark: Color(red: 125 / 255, green: 211 / 255, blue: 252 / 255).opacity(0.22)
    )
    /// Background of an inactive category chip.
    static let chipInactiveBg = adaptive(light: 0xEFF4FE, dark: 0x172538)

    // MARK: Status

    static let success = adaptive(light: 0x16A34A, dark: 0x4ADE80)
    static let warning = adaptive(light: 0xB45309, dark: 0xFBBF24)
    static let danger = adaptive(light: 0xDC2626, dark: 0xF87171)

    /// Soft blue gradient used as the full-screen background.
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                adaptive(light: 0xF8FBFF, dark: 0x07111F),
                adaptive(light: 0xEEF5FF, dark: 0x0B1628),
                adaptive(light: 0xE7EFFC, dark: 0x0B1628)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Helpers

    /// Builds an adaptive `Color` from two hex values (light + dark).
    static func adaptive(light: UInt32, dark: UInt32) -> Color {
        adaptiveColor(light: color(hex: light), dark: color(hex: dark))
    }

    /// Builds an adaptive `Color` from two fully-formed colors.
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// Converts a 0xRRGGBB hex value to an opaque `Color`.
    static func color(hex: UInt32) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
}
