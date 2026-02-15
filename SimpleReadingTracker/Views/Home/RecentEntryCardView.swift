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
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .italic(isQuote)

            Spacer()

            Text(bookTitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .frame(width: 200, height: 180, alignment: .topLeading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary)
        )
    }

    private var isQuote: Bool {
        if case .quote = entry { return true }
        return false
    }
}
