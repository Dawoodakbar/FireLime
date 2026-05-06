import SwiftUI

struct DesignSystem {
    
    struct Colors {
        static let primary = Color(hex: "4F46E5") // Indigo
        static let secondary = Color(hex: "10B981") // Emerald
        static let background = Color(hex: "F9FAFB")
        static let surface = Color.white
        static let textPrimary = Color(hex: "111827")
        static let textSecondary = Color(hex: "6B7280")
        static let error = Color(hex: "EF4444")
        
        static let gradientPrimary = LinearGradient(
            colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let full: CGFloat = 999
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
