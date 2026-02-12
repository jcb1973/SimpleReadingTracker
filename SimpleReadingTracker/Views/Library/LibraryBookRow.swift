import SwiftUI

struct LibraryBookRow: View {
    let book: Book
    let matchReasons: [MatchReason]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
            }

            if !matchReasons.isEmpty {
                SearchMatchIndicator(reasons: matchReasons)
            }

            if !book.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(book.tags.prefix(3)) { tag in
                        TagChipView(name: tag.displayName)
                    }
                    if book.tags.count > 3 {
                        Text("+\(book.tags.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
