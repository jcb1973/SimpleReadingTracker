import Foundation
import Observation
import SwiftData

@Observable
final class BookDetailViewModel {
    private let modelContext: ModelContext

    let book: Book
    private(set) var error: String?

    var notes: [Note] {
        book.notes.sorted { $0.createdAt > $1.createdAt }
    }

    var quotes: [Quote] {
        book.quotes.sorted { $0.createdAt > $1.createdAt }
    }

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

    func addTag(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let lowered = trimmed.lowercased()
        let existing = findTag(named: lowered)
        let tag = existing ?? Tag(name: trimmed)
        if existing == nil {
            modelContext.insert(tag)
        }

        guard !book.tags.contains(where: { $0.persistentModelID == tag.persistentModelID }) else { return }
        book.tags.append(tag)
        save()
    }

    func removeTag(_ tag: Tag) {
        book.tags.removeAll { $0.persistentModelID == tag.persistentModelID }
        save()
    }

    private func findTag(named lowercaseName: String) -> Tag? {
        let descriptor = FetchDescriptor<Tag>()
        let tags = (try? modelContext.fetch(descriptor)) ?? []
        return tags.first { $0.name == lowercaseName }
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
