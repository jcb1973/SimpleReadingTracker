import SwiftUI

struct LibraryBookRow: View {
    let book: Book
    let matchReasons: [MatchReason]
    var onStatusTapped: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(book.title)
                        .font(.headline)
                    Text(book.authorNames)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                StatusBadge(status: book.status)
                    .contentShape(Capsule())
                    .onTapGesture {
                        onStatusTapped?()
                    }
                    .accessibilityLabel(book.status.displayName)
                    .accessibilityHint("Cycle reading status")
            }

            if !matchReasons.isEmpty {
                SearchMatchIndicator(reasons: matchReasons)
            }

            if !book.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(book.tags.prefix(3)) { tag in
                        TagChipView(name: tag.displayName, color: tag.resolvedColor)
                    }
                    if book.tags.count > 3 {
                        Text("+\(book.tags.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("\(book.tags.count - 3) more tags")
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
