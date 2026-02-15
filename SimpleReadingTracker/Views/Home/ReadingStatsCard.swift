import SwiftUI

struct ReadingStatsCard: View {
    let statusCounts: [ReadingStatus: Int]
    let onStatusTapped: (ReadingStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Library")
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(ReadingStatus.allCases) { status in
                    Button {
                        onStatusTapped(status)
                    } label: {
                        statusCell(status)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func statusCell(_ status: ReadingStatus) -> some View {
        VStack(spacing: 1) {
            Image(systemName: status.systemImage)
                .font(.caption)
                .frame(height: 10)
                .foregroundStyle(color(for: status))

            Text("\(statusCounts[status] ?? 0)")
                .font(.subheadline)
                .fontWeight(.bold)
                .monospacedDigit()

            Text(status.displayName)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color(for: status).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func color(for status: ReadingStatus) -> Color {
        switch status {
        case .toRead: .blue
        case .reading: .orange
        case .read: .green
        }
    }
}
