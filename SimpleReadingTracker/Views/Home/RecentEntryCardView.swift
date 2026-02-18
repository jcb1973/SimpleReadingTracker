import SwiftUI

struct RecentEntryCardView: View {
    let entry: RecentEntry

    private var typeLabel: String {
        switch entry {
        case .note: "Note"
        case .quote: "Quote"
        }
    }

    private var typeColor: Color {
        switch entry {
        case .note: .blue
        case .quote: .orange
        }
    }

    private var contentPreview: String {
        switch entry {
        case .note(let n): n.content
        case .quote(let q): q.text
        }
    }

    private var bookTitle: String {
        entry.book?.title ?? ""
    }

    var body: some View {
        TextCard(height: 195, accessibilityLabel: "\(typeLabel) from \(bookTitle): \(contentPreview)") {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(typeLabel)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(typeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(typeColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Spacer()

                    Text(entry.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(contentPreview)
                    .font(.subheadline)
                    .lineLimit(6)
                    .multilineTextAlignment(.leading)
                    .italic(isQuote)

                Spacer()

                Text(bookTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private var isQuote: Bool {
        if case .quote = entry { return true }
        return false
    }
}
