import SwiftUI

enum TagColor: String, CaseIterable, Sendable {
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case blue
    case purple
    case pink
    case brown

    var color: Color {
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
