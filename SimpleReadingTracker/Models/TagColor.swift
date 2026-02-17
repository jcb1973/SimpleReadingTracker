import SwiftUI

enum TagColor: String, Sendable {
    case red
    case orange
    case yellow
    case green
    case mint // legacy — mapped to teal
    case teal
    case blue
    case purple
    case pink
    case brown // legacy — mapped to orange

    /// The 8 colours shown in the picker. Legacy values (mint, brown) are excluded.
    static let pickerOptions: [TagColor] = [
        .red, .orange, .yellow, .green, .teal, .blue, .purple, .pink
    ]

    /// Maps legacy colours to their replacement.
    var canonical: TagColor {
        switch self {
        case .mint: .teal
        case .brown: .orange
        default: self
        }
    }

    var color: Color {
        canonical._color
    }

    private var _color: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .green: .green
        case .mint: .mint
        case .teal: .teal
        case .blue: .blue
        case .purple: .purple
        case .pink: .pink
        case .brown: .brown
        }
    }
}
