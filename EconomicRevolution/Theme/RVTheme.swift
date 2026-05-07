import SwiftUI

enum RV {
    static let bg = Color(hex: 0x0B1220)
    static let surface = Color(hex: 0x121A2B)
    static let card = Color(hex: 0x18213A)
    static let cardElevated = Color(hex: 0x1E2A4A)

    static let accent = Color(hex: 0x3B82F6)
    static let accentBright = Color(hex: 0x60A5FA)
    static let accentDark = Color(hex: 0x1D4ED8)
    static let onAccent = Color(hex: 0xF1F5F9)

    static let gold = accent
    static let goldBright = accentBright
    static let goldDark = accentDark
    static let onGold = onAccent

    static let emerald = accentBright
    static let emeraldDark = accentDark

    static let income = Color(hex: 0x34D399)
    static let expense = Color(hex: 0xF87171)

    static let text = Color(hex: 0xF1F5F9)
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textMuted = Color(hex: 0x64748B)
    static let border = Color(hex: 0x1F2A44)
    static let hairline = Color(hex: 0x1F2A44)

    static let radius: CGFloat = 16
    static let radiusSm: CGFloat = 10
    static let radiusLg: CGFloat = 22

    static let accentGrad = LinearGradient(
        colors: [Color(hex: 0x60A5FA), Color(hex: 0x3B82F6), Color(hex: 0x1D4ED8)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let goldGrad = accentGrad
    static let emeraldGrad = accentGrad

    static let cardGrad = LinearGradient(
        colors: [Color(hex: 0x1E2A4A), Color(hex: 0x121A2B)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension Font {
    static let rvTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let rvH2 = Font.system(size: 20, weight: .bold)
    static let rvH3 = Font.system(size: 17, weight: .semibold)
    static let rvBody = Font.system(size: 15)
    static let rvCaption = Font.system(size: 12, weight: .medium)
    static let rvAmount = Font.system(size: 32, weight: .heavy, design: .rounded)
    static let rvBigAmount = Font.system(size: 42, weight: .heavy, design: .rounded)
    static let rvMono = Font.system(size: 13, weight: .semibold, design: .monospaced)
    static let rvPercent = Font.system(size: 14, weight: .bold, design: .rounded)
}

struct RVCardMod: ViewModifier {
    var elevated: Bool = false
    var glow: Color? = nil

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: RV.radius)
                    .fill(elevated ? RV.cardElevated : RV.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RV.radius)
                    .stroke(RV.hairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: RV.radius))
    }
}

struct RVPrimaryButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(RV.onAccent)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(RV.accentGrad)
            .clipShape(RoundedRectangle(cornerRadius: RV.radiusSm))
    }
}

extension View {
    func rvCard(elevated: Bool = false, glow: Color? = nil) -> some View {
        modifier(RVCardMod(elevated: elevated, glow: glow))
    }
    func rvPrimaryButton() -> some View {
        modifier(RVPrimaryButton())
    }
}
