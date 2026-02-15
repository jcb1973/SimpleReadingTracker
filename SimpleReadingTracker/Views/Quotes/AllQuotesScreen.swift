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
            bookHeader
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))

            ForEach(filteredQuotes) { quote in
                QuoteRowView(quote: quote) {
                    editingQuote = quote
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
        }
        .listStyle(.plain)
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

    private var bookHeader: some View {
        HStack(spacing: 12) {
            BookCoverView(
                coverImageData: book.coverImageData,
                coverImageURL: book.coverImageURL,
                size: CGSize(width: 40, height: 60),
                cornerRadius: 6
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                if !book.authorNames.isEmpty {
                    Text(book.authorNames)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

private struct QuoteRowView: View {
    let quote: Quote
    let action: () -> Void

    @State private var isExpanded = false
    @State private var truncatedHeight: CGFloat = 0
    @State private var fullHeight: CGFloat = 0

    private var isTruncated: Bool {
        fullHeight > truncatedHeight + 1
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                quoteTexts(limited: !isExpanded)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear { truncatedHeight = geo.size.height }
                    })
                    .background(
                        quoteTexts(limited: false)
                            .fixedSize(horizontal: false, vertical: true)
                            .hidden()
                            .background(GeometryReader { geo in
                                Color.clear.onAppear { fullHeight = geo.size.height }
                            })
                    )

                if isTruncated {
                    Button {
                        withAnimation { isExpanded.toggle() }
                    } label: {
                        Text(isExpanded ? "Less" : "More")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.tint)
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    if let page = quote.pageNumber {
                        Text("p. \(page)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Text(quote.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private func quoteTexts(limited: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(quote.text)
                .font(.body)
                .italic()
                .lineLimit(limited ? 3 : nil)
                .foregroundStyle(.primary)

            if let comment = quote.comment, !comment.isEmpty {
                Text(comment)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(limited ? 2 : nil)
            }
        }
    }
}
