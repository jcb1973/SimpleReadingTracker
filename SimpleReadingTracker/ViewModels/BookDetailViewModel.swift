import Foundation
import Observation
import SwiftData

@Observable
final class BookDetailViewModel {
    private let modelContext: ModelContext
    private var noteSaveTask: Task<Void, Never>?

    let book: Book
    var noteText: String {
        didSet { debounceSaveNotes() }
    }
    private(set) var error: String?

    init(book: Book, modelContext: ModelContext) {
        self.book = book
        self.modelContext = modelContext
        self.noteText = book.userNotes ?? ""
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

    func cycleStatus() {
        let next: ReadingStatus = switch book.status {
        case .toRead: .reading
        case .reading: .read
        case .read: .toRead
        }
        updateStatus(next)
    }

    func updateRating(_ rating: Int?) {
        book.rating = rating
        save()
    }

    func updateCoverImage(_ data: Data?) {
        book.coverImageData = data
        save()
    }

    func saveNotesNow() {
        noteSaveTask?.cancel()
        book.userNotes = noteText.isEmpty ? nil : noteText
        save()
    }

    private func debounceSaveNotes() {
        noteSaveTask?.cancel()
        noteSaveTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            self?.saveNotesNow()
        }
    }

    func deleteBook() {
        modelContext.delete(book)
        do {
            try modelContext.save()
        } catch {
            self.error = PersistenceError.deleteFailed(underlying: error).localizedDescription
        }
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
