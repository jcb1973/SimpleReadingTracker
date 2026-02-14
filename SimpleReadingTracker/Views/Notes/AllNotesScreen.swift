import SwiftUI

struct AllNotesScreen: View {
    let book: Book

    @State private var editingNote: Note?
    @State private var showingAddNote = false

    private var sortedNotes: [Note] {
        book.notes.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        List {
            ForEach(sortedNotes) { note in
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
        .overlay {
            if sortedNotes.isEmpty {
                ContentUnavailableView(
                    "No Notes",
                    systemImage: "note.text",
                    description: Text("Tap + to add your first note.")
                )
            }
        }
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddNote = true
                } label: {
                    Image(systemName: "plus")
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
