import Foundation
import Observation
import SwiftData

@Observable
final class BookDetailViewModel {
    private let modelContext: ModelContext

    let book: Book
    var noteText = ""
    private(set) var error: String?

    init(book: Book, modelContext: ModelContext) {
        self.book = book
        self.modelContext = modelContext
    }

    func updateStatus(_ status: ReadingStatus) {
        book.status = status
        if status == .reading, book.dateStarted == nil {
            book.dateStarted = .now
        }
        if status == .read {
            book.dateFinished = .now
        }
        save()
    }

    func updateRating(_ rating: Int?) {
        book.rating = rating
        save()
    }

    func updateCoverImage(_ data: Data?) {
        book.coverImageData = data
        save()
    }

    func addNote() {
        let content = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }

        let note = Note(content: content, book: book)
        book.notes.append(note)
        noteText = ""
        save()
    }

    func deleteNote(_ note: Note) {
        book.notes.removeAll { $0.persistentModelID == note.persistentModelID }
        modelContext.delete(note)
        save()
    }

    func deleteBook() {
        modelContext.delete(book)
        do {
            try modelContext.save()
        } catch {
            self.error = PersistenceError.deleteFailed(underlying: error).localizedDescription
        }
    }

    var sortedNotes: [Note] {
        book.notes.sorted { $0.createdAt > $1.createdAt }
    }

    private func save() {
        do {
            try modelContext.save()
            error = nil
        } catch {
            self.error = PersistenceError.saveFailed(underlying: error).localizedDescription
        }
    }
}
