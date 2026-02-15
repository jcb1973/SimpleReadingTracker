import SwiftUI

enum NotesQuotesTab: Int, Hashable {
    case quotes = 0
    case notes = 1
}

struct NotesQuotesSection: View {
    let book: Book
    var initialTab: NotesQuotesTab = .quotes

    @State private var selectedTab = 0
    @State private var showingAddNote = false
    @State private var showingAddQuote = false
    @State private var editingNote: Note?
    @State private var editingQuote: Quote?

    private var sortedNotes: [Note] {
        book.notes.sorted { $0.createdAt > $1.createdAt }
    }

    private var sortedQuotes: [Quote] {
        book.quotes.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Content", selection: $selectedTab) {
                Text("Quotes").tag(0).font(.headline)
                Text("Notes").tag(1).font(.headline)
            }
            .pickerStyle(.segmented)
            .onAppear { selectedTab = initialTab.rawValue }

            if selectedTab == 0 {
                quotesContent
            } else {
                notesContent
            }
        }
        .sheet(isPresented: $showingAddNote) {
            NoteEditorSheet(book: book)
        }
        .sheet(isPresented: $showingAddQuote) {
            QuoteEditorSheet(book: book)
        }
        .sheet(item: $editingNote) { note in
            NoteEditorSheet(book: book, note: note)
        }
        .sheet(item: $editingQuote) { quote in
            QuoteEditorSheet(book: book, quote: quote)
        }
    }

    private var notesContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                actionColumn(
                    hasItems: !sortedNotes.isEmpty,
                    addAction: { showingAddNote = true },
                    destination: AllNotesScreen(book: book),
                    viewAllLabel: "See all notes"
                )

                ForEach(sortedNotes) { note in
                    NoteCardView(note: note)
                        .onTapGesture { editingNote = note }
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private var quotesContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                actionColumn(
                    hasItems: !sortedQuotes.isEmpty,
                    addAction: { showingAddQuote = true },
                    destination: AllQuotesScreen(book: book),
                    viewAllLabel: "See all quotes"
                )

                ForEach(sortedQuotes) { quote in
                    QuoteCardView(quote: quote)
                        .onTapGesture { editingQuote = quote }
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private func actionColumn<D: View>(
        hasItems: Bool,
        addAction: @escaping () -> Void,
        destination: D,
        viewAllLabel: String
    ) -> some View {
        VStack(spacing: 8) {
            AddCardView(action: addAction)

            if hasItems {
                NavigationLink {
                    destination
                } label: {
                    Text("View all")
                        .font(.subheadline)
                }
                .accessibilityLabel(viewAllLabel)
            }

            Spacer(minLength: 0)
        }
        .frame(height: 150)
    }
}
