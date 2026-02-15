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
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    AddCardView(compact: sortedNotes.isEmpty) { showingAddNote = true }

                    ForEach(sortedNotes) { note in
                        NoteCardView(note: note)
                            .onTapGesture { editingNote = note }
                    }
                }
                .padding(.horizontal, 1)
            }

            if !sortedNotes.isEmpty {
                NavigationLink {
                    AllNotesScreen(book: book)
                } label: {
                    Text("See all")
                        .font(.subheadline)
                }
                .accessibilityLabel("See all notes")
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var quotesContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    AddCardView(compact: sortedQuotes.isEmpty) { showingAddQuote = true }

                    ForEach(sortedQuotes) { quote in
                        QuoteCardView(quote: quote)
                            .onTapGesture { editingQuote = quote }
                    }
                }
                .padding(.horizontal, 1)
            }

            if !sortedQuotes.isEmpty {
                NavigationLink {
                    AllQuotesScreen(book: book)
                } label: {
                    Text("See all")
                        .font(.subheadline)
                }
                .accessibilityLabel("See all quotes")
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
