import SwiftUI

struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        TextCard(accessibilityLabel: quoteAccessibilityLabel) {
            VStack(alignment: .leading, spacing: 8) {
                Text(quote.text)
                    .font(.subheadline)
                    .italic()
                    .lineLimit(6)
                    .multilineTextAlignment(.leading)

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
        }
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
