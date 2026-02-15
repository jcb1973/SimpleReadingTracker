import SwiftUI

struct AllNotesScreen: View {
    let book: Book

    @State private var editingNote: Note?
    @State private var showingAddNote = false
    @State private var searchText = ""
    @State private var sortNewestFirst = true

    private var filteredNotes: [Note] {
        var result = book.notes

        if !searchText.isEmpty {
            result = result.filter { note in
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result.sorted { lhs, rhs in
            sortNewestFirst ? lhs.createdAt > rhs.createdAt : lhs.createdAt < rhs.createdAt
        }
    }

    var body: some View {
        List {
            ForEach(filteredNotes) { note in
                Button {
                    editingNote = note
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.content)
                            .font(.body)
                            .lineLimit(3)
                            .foregroundStyle(.primary)
                        Text(note.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search notes...")
        .overlay {
            if filteredNotes.isEmpty {
                if !searchText.isEmpty {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text("Tap + to add your first note.")
                    )
                }
            }
        }
        .navigationTitle("Notes")
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
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            NoteEditorSheet(book: book)
        }
        .sheet(item: $editingNote) { note in
            NoteEditorSheet(book: book, note: note)
        }
    }
}
