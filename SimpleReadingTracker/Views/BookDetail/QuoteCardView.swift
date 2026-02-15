import SwiftUI

struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text)
                .font(.subheadline)
                .italic()
                .lineLimit(quote.comment != nil ? 3 : 5)
                .multilineTextAlignment(.leading)

            if let comment = quote.comment {
                Text(comment)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            HStack {
                if let page = quote.pageNumber {
                    Text("p. \(page)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(quote.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(width: 200, height: 150, alignment: .topLeading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(quoteAccessibilityLabel)
    }

    private var quoteAccessibilityLabel: String {
        var parts = [quote.text]
        if let comment = quote.comment {
            parts.append(comment)
        }
        if let page = quote.pageNumber {
            parts.append("page \(page)")
        }
        return parts.joined(separator: ", ")
    }
}
