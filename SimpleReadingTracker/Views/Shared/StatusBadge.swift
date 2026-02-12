import SwiftUI

struct StatusBadge: View {
    let status: ReadingStatus

    var body: some View {
        Label(status.displayName, systemImage: status.systemImage)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
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
