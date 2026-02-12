import SwiftUI

struct StatusBadge: View {
    let status: ReadingStatus

    var body: some View {
        Label(status.displayName, systemImage: status.systemImage)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor.opacity(0.15))
            .foregroundStyle(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .toRead: .blue
        case .reading: .orange
        case .read: .green
        }
    }
}
