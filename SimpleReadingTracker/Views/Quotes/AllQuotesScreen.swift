import SwiftUI

struct AllQuotesScreen: View {
    let book: Book

    @State private var editingQuote: Quote?
    @State private var showingAddQuote = false
    @State private var searchText = ""
    @State private var sortNewestFirst = true
    @State private var filterHasComment = false

    private var filteredQuotes: [Quote] {
        var result = book.quotes

        if filterHasComment {
            result = result.filter { quote in
                guard let comment = quote.comment else { return false }
                return !comment.isEmpty
            }
        }

        if !searchText.isEmpty {
            result = result.filter { quote in
                quote.text.localizedCaseInsensitiveContains(searchText)
                || (quote.comment?.localizedCaseInsensitiveContains(searchText) ?? false)
                || quote.pageNumber.map({ String($0).contains(searchText) }) ?? false
            }
        }

        return result.sorted { lhs, rhs in
            sortNewestFirst ? lhs.createdAt > rhs.createdAt : lhs.createdAt < rhs.createdAt
        }
    }

    private var hasActiveFilters: Bool {
        filterHasComment || !searchText.isEmpty
    }

    var body: some View {
        List {
            ForEach(filteredQuotes) { quote in
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
        .searchable(text: $searchText, prompt: "Search quotes...")
        .overlay {
            if filteredQuotes.isEmpty {
                if hasActiveFilters {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView(
                        "No Quotes",
                        systemImage: "quote.opening",
                        description: Text("Tap + to add your first quote.")
                    )
                }
            }
        }
        .navigationTitle("Quotes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    Menu {
                        Section("Sort By") {
                            Button {
                                sortNewestFirst = true
                            } label: {
                                if sortNewestFirst { Label("Newest First", systemImage: "checkmark") }
                                else { Text("Newest First") }
                            }
                            Button {
                                sortNewestFirst = false
                            } label: {
                                if !sortNewestFirst { Label("Oldest First", systemImage: "checkmark") }
                                else { Text("Oldest First") }
                            }
                        }
                        Section("Filter") {
                            Button {
                                filterHasComment.toggle()
                            } label: {
                                if filterHasComment { Label("Has Comment", systemImage: "checkmark") }
                                else { Text("Has Comment") }
                            }
                        }
                    } label: {
                        Label("Sort & Filter", systemImage: filterHasComment
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }
                    Button {
                        showingAddQuote = true
                    } label: {
                        Image(systemName: "plus")
                    }
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
