import SwiftUI

public enum ThemeType: String, CaseIterable {
    case light, dark, coloured
}

public extension ThemeType {
    var backgroundColor: Color {
        switch self {
        case .light:    return Color(hex: "F2F2F2")
        case .dark:     return Color(hex: "0A0E3F")
        case .coloured: return Color(hex: "0000FF")
        }
    }

    var logoColor: Color {
        switch self {
        case .light:    return Color(hex: "0000FF")
        case .dark:     return .white
        case .coloured: return .white
        }
    }

    var toggleInactiveBackground: Color {
        switch self {
        case .light:    return Color(hex: "ADD8FF")
        case .dark:     return Color.white.opacity(0.12)
        case .coloured: return Color(hex: "00C8FF").opacity(0.55)
        }
    }

    var toggleActiveBackground: Color {
        switch self {
        case .light:    return Color(hex: "0000FF")
        case .dark:     return .white
        case .coloured: return .white
        }
    }

    var toggleInactiveText: Color {
        switch self {
        case .light:    return Color(hex: "0000FF")
        case .dark:     return .white
        case .coloured: return .white
        }
    }

    var toggleActiveText: Color {
        switch self {
        case .light:    return .white
        case .dark:     return Color(hex: "0A0E3F")
        case .coloured: return Color(hex: "0000FF")
        }
    }

    var pulisciBackground: Color {
        switch self {
        case .light:    return Color(hex: "0000FF")
        case .dark:     return Color(hex: "1A3ACC")
        case .coloured: return .white
        }
    }

    var pulisciText: Color {
        switch self {
        case .light:    return .white
        case .dark:     return .white
        case .coloured: return Color(hex: "0000FF")
        }
    }

    var feedbackColor: Color {
        switch self {
        case .light:    return Color(hex: "0000FF").opacity(0.7)
        case .dark:     return Color.white.opacity(0.7)
        case .coloured: return Color.white.opacity(0.85)
        }
    }

    var swatchColor: Color {
        switch self {
        case .light:    return Color(hex: "DCDCDC")
        case .dark:     return Color(hex: "0A0E3F")
        case .coloured: return Color(hex: "0000FF")
        }
    }
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
