import Foundation
import Observation
import SwiftData
import UIKit

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

    func backfillCoverImageIfNeeded() async {
        guard book.coverImageData == nil,
              let urlString = book.coverImageURL,
              let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }

            let maxWidth: CGFloat = 600
            let scale = image.size.width > maxWidth ? maxWidth / image.size.width : 1.0
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let compressed = renderer.jpegData(withCompressionQuality: 0.7) { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }

            book.coverImageData = compressed
            save()
        } catch {
            // Will retry next time the detail screen is opened
        }
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
