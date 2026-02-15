import Foundation
import Observation
import SwiftData

enum RecentEntry: Identifiable {
    case note(Note)
    case quote(Quote)

    var id: String {
        switch self {
        case .note(let n): "note-\(n.persistentModelID)"
        case .quote(let q): "quote-\(q.persistentModelID)"
        }
    }

    var date: Date {
        switch self {
        case .note(let n): n.createdAt
        case .quote(let q): q.createdAt
        }
    }

    var book: Book? {
        switch self {
        case .note(let n): n.book
        case .quote(let q): q.book
        }
    }
}

@Observable
final class HomeViewModel {
    private let modelContext: ModelContext

    private(set) var currentlyReading: [Book] = []
    private(set) var statusCounts: [ReadingStatus: Int] = [:]
    private(set) var ratingCounts: [Int: Int] = [:]
    private(set) var recentEntries: [RecentEntry] = []
    private(set) var error: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchBooks() {
        do {
            let readingStatus = ReadingStatus.reading.rawValue
            let readingDescriptor = FetchDescriptor<Book>(
                predicate: #Predicate { $0.statusRawValue == readingStatus },
                sortBy: [SortDescriptor(\.dateStarted, order: .reverse)]
            )
            currentlyReading = try modelContext.fetch(readingDescriptor)

            var counts: [ReadingStatus: Int] = [:]
            for status in ReadingStatus.allCases {
                let raw = status.rawValue
                let desc = FetchDescriptor<Book>(
                    predicate: #Predicate { $0.statusRawValue == raw }
                )
                counts[status] = (try? modelContext.fetchCount(desc)) ?? 0
            }
            statusCounts = counts

            var ratings: [Int: Int] = [:]
            for star in 1...5 {
                let desc = FetchDescriptor<Book>(
                    predicate: #Predicate { $0.rating == star }
                )
                ratings[star] = (try? modelContext.fetchCount(desc)) ?? 0
            }
            ratingCounts = ratings

            fetchRecentEntries()

            error = nil
        } catch {
            self.error = PersistenceError.fetchFailed(underlying: error).localizedDescription
        }
    }

    private func fetchRecentEntries() {
        var notesDescriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        notesDescriptor.fetchLimit = 10

        var quotesDescriptor = FetchDescriptor<Quote>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        quotesDescriptor.fetchLimit = 10

        let notes = (try? modelContext.fetch(notesDescriptor)) ?? []
        let quotes = (try? modelContext.fetch(quotesDescriptor)) ?? []

        let combined: [RecentEntry] =
            notes.map { .note($0) } + quotes.map { .quote($0) }

        recentEntries = combined.sorted { $0.date > $1.date }
    }
}
