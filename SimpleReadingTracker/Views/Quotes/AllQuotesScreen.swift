import SwiftUI

struct AllQuotesScreen: View {
    let book: Book

    @State private var editingQuote: Quote?
    @State private var showingAddQuote = false

    private var sortedQuotes: [Quote] {
        book.quotes.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        List {
            ForEach(sortedQuotes) { quote in
                Button {
                    editingQuote = quote
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quote.text)
                            .font(.body)
                            .italic()
                            .lineLimit(3)
                            .foregroundStyle(.primary)
                        HStack {
                            if let page = quote.pageNumber {
                                Text("p. \(page)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(quote.createdAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .overlay {
            if sortedQuotes.isEmpty {
                ContentUnavailableView(
                    "No Quotes",
                    systemImage: "quote.opening",
                    description: Text("Tap + to add your first quote.")
                )
            }
        }
        .navigationTitle("Quotes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddQuote = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddQuote) {
            QuoteEditorSheet(book: book)
        }
        .sheet(item: $editingQuote) { quote in
            QuoteEditorSheet(book: book, quote: quote)
        }
    }
}
