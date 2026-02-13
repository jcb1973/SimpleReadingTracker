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
        VStack(spacing: 6) {
            Image(systemName: status.systemImage)
                .font(.title2)
                .frame(height: 28)
                .foregroundStyle(color(for: status))

            Text("\(statusCounts[status] ?? 0)")
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()

            Text(status.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color(for: status).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func color(for status: ReadingStatus) -> Color {
        switch status {
        case .toRead: .blue
        case .reading: .orange
        case .read: .green
        }
    }
}
