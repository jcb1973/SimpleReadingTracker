import Foundation
import Observation
import SwiftData

@Observable
final class LibraryViewModel {
    private let modelContext: ModelContext
    private let searchService = SearchService()

    var searchText = ""
    var statusFilter: ReadingStatus?
    var ratingFilter: Int?
    var sortOption: SortOption = .dateAdded
    var sortAscending = false

    private(set) var searchResults: [SearchResult] = []
    private(set) var error: String?

    var books: [Book] {
        searchResults.map(\.book)
    }

    var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || statusFilter != nil
            || ratingFilter != nil
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchBooks() {
        do {
            let predicate = searchService.buildPredicate(
                searchText: searchText,
                statusFilter: statusFilter,
                ratingFilter: ratingFilter
            )
            let sortDescriptors = searchService.buildSortDescriptors(
                option: sortOption,
                ascending: sortAscending
            )

            let descriptor = FetchDescriptor<Book>(
                predicate: predicate,
                sortBy: sortDescriptors
            )
            let fetched = try modelContext.fetch(descriptor)

            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                searchResults = fetched.map { SearchResult(book: $0, matchReasons: []) }
            } else {
                searchResults = searchService.filterByRelationships(
                    books: fetched,
                    searchText: searchText
                )

                let predicateMatchedIDs = Set(fetched.map(\.persistentModelID))
                let allDescriptor = FetchDescriptor<Book>()
                let allBooks = try modelContext.fetch(allDescriptor)
                let additionalResults = searchService.filterByRelationships(
                    books: allBooks.filter { !predicateMatchedIDs.contains($0.persistentModelID) },
                    searchText: searchText
                )
                searchResults.append(contentsOf: additionalResults)
            }

            error = nil
        } catch {
            self.error = PersistenceError.fetchFailed(underlying: error).localizedDescription
        }
    }

    func deleteBook(_ book: Book) {
        modelContext.delete(book)
        do {
            try modelContext.save()
            fetchBooks()
        } catch {
            self.error = PersistenceError.deleteFailed(underlying: error).localizedDescription
        }
    }

    func updateStatus(for book: Book, to status: ReadingStatus) {
        book.status = status
        if status == .reading, book.dateStarted == nil {
            book.dateStarted = .now
        }
        if status == .read {
            book.dateFinished = .now
        }
        do {
            try modelContext.save()
            fetchBooks()
        } catch {
            self.error = PersistenceError.saveFailed(underlying: error).localizedDescription
        }
    }

    func matchReasons(for book: Book) -> [MatchReason] {
        searchResults.first { $0.book.persistentModelID == book.persistentModelID }?.matchReasons ?? []
    }
}
