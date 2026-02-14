import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class NoteEditorViewModel {
    var content: String
    let note: Note?

    init(note: Note? = nil) {
        self.note = note
        self.content = note?.content ?? ""
    }

    var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save(for book: Book, modelContext: ModelContext) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let note {
            note.content = trimmed
        } else {
            let newNote = Note(content: trimmed, book: book)
            modelContext.insert(newNote)
        }

        try? modelContext.save()
    }

    func delete(modelContext: ModelContext) {
        guard let note else { return }
        modelContext.delete(note)
        try? modelContext.save()
    }
}
