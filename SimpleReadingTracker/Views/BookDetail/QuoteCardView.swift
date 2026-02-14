import SwiftUI

struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text)
                .font(.subheadline)
                .italic()
                .lineLimit(5)
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
        .padding(12)
        .frame(width: 200, height: 150, alignment: .topLeading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary)
        )
    }
}
