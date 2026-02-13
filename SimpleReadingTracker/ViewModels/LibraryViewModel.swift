import Foundation
import Observation
import SwiftData

enum TagFilterMode: String, Sendable {
    case and
    case or
}

@Observable
final class LibraryViewModel {
    private let modelContext: ModelContext
    private let searchService = SearchService()
    private let pageSize = 10
    private var isLoadingMore = false
    private var searchTask: Task<Void, Never>?

    var searchText = ""
    var statusFilter: ReadingStatus?
    var ratingFilter: Int?
    var tagFilters: [Tag] = []
    var tagFilterMode: TagFilterMode = .and
    var sortOption: SortOption = .dateAdded
    var sortAscending = false

    private(set) var searchResults: [SearchResult] = []
    private(set) var allTags: [Tag] = []
    private(set) var hasMore = true
    private(set) var error: String?

    var books: [Book] {
        searchResults.map(\.book)
    }

    var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || statusFilter != nil
            || ratingFilter != nil
            || !tagFilters.isEmpty
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public

    func fetchBooks() {
        searchTask?.cancel()
        searchResults = []
        hasMore = true
        fetchTags()

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty, tagFilters.isEmpty {
            loadNextPage()
        } else if trimmed.isEmpty {
            loadTagFiltered()
        } else {
            performSearch()
        }
    }

    func fetchTags() {
        do {
            let descriptor = FetchDescriptor<Tag>()
            let tags = try modelContext.fetch(descriptor)
            allTags = tags
                .filter { !$0.books.isEmpty }
                .sorted { $0.books.count > $1.books.count }
        } catch {
            allTags = []
        }
    }

    func searchTextDidChange() {
        searchTask?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            searchResults = []
            hasMore = true
            if tagFilters.isEmpty {
                loadNextPage()
            } else {
                loadTagFiltered()
            }
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            searchResults = []
            hasMore = true
            performSearch()
        }
    }

    func toggleTag(_ tag: Tag) {
        if let index = tagFilters.firstIndex(where: { $0.persistentModelID == tag.persistentModelID }) {
            tagFilters.remove(at: index)
        } else {
            tagFilters.append(tag)
        }
        fetchBooks()
    }

    func loadMore() {
        guard hasMore, !isLoadingMore else { return }
        loadNextPage()
    }

    func deleteBook(_ book: Book) {
        let bookID = book.persistentModelID
        searchResults.removeAll { $0.book.persistentModelID == bookID }
        modelContext.delete(book)
        do {
            try modelContext.save()
            fetchTags()
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

    // MARK: - Tag-filtered browsing

    private func loadTagFiltered() {
        guard !tagFilters.isEmpty else { return }
        let filterIDs = Set(tagFilters.map(\.persistentModelID))

        let candidateBooks: Set<PersistentIdentifier>
        var bookPool: [PersistentIdentifier: Book] = [:]
        for tag in tagFilters {
            for book in tag.books {
                bookPool[book.persistentModelID] = book
            }
        }

        switch tagFilterMode {
        case .and:
            candidateBooks = bookPool.keys.filter { bookID in
                guard let book = bookPool[bookID] else { return false }
                let bookTagIDs = Set(book.tags.map(\.persistentModelID))
                return filterIDs.isSubset(of: bookTagIDs)
            }.reduce(into: Set<PersistentIdentifier>()) { $0.insert($1) }
        case .or:
            candidateBooks = Set(bookPool.keys)
        }

        var results = candidateBooks.compactMap { bookPool[$0] }.filter { book in
            if let statusFilter, book.status != statusFilter { return false }
            if let ratingFilter, book.rating != ratingFilter { return false }
            return true
        }
        results.sort { sortCompare($0, $1) }
        searchResults = results.map { SearchResult(book: $0, matchReasons: []) }
        hasMore = false
        error = nil
    }

    // MARK: - Paginated browsing

    private func loadNextPage() {
        do {
            isLoadingMore = true
            let predicate = searchService.buildPredicate(
                searchText: "",
                statusFilter: statusFilter,
                ratingFilter: ratingFilter
            )
            let sortDescriptors = searchService.buildSortDescriptors(
                option: sortOption,
                ascending: sortAscending
            )
            var descriptor = FetchDescriptor<Book>(
                predicate: predicate,
                sortBy: sortDescriptors
            )
            descriptor.fetchLimit = pageSize
            descriptor.fetchOffset = searchResults.count
            let fetched = try modelContext.fetch(descriptor)
            searchResults.append(contentsOf: fetched.map { SearchResult(book: $0, matchReasons: []) })
            hasMore = fetched.count == pageSize
            isLoadingMore = false
            error = nil
        } catch {
            isLoadingMore = false
            self.error = PersistenceError.fetchFailed(underlying: error).localizedDescription
        }
    }

    // MARK: - Targeted search

    private func performSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        do {
            // 1. Books matching title/isbn via predicate (already filtered by status/rating)
            let predicate = searchService.buildPredicate(
                searchText: searchText,
                statusFilter: statusFilter,
                ratingFilter: ratingFilter
            )
            let predicateBooks = try modelContext.fetch(FetchDescriptor<Book>(predicate: predicate))

            // 2. Authors matching search → their books
            let authorPredicate = #Predicate<Author> {
                $0.name.localizedStandardContains(trimmed)
            }
            let matchingAuthors = try modelContext.fetch(
                FetchDescriptor<Author>(predicate: authorPredicate)
            )

            // 3. Tags matching search → their books
            let tagPredicate = #Predicate<Tag> {
                $0.name.localizedStandardContains(trimmed)
                    || $0.displayName.localizedStandardContains(trimmed)
            }
            let matchingTags = try modelContext.fetch(
                FetchDescriptor<Tag>(predicate: tagPredicate)
            )

            // 4. Notes matching search → their books
            let notePredicate = #Predicate<Note> {
                $0.content.localizedStandardContains(trimmed)
            }
            let matchingNotes = try modelContext.fetch(
                FetchDescriptor<Note>(predicate: notePredicate)
            )

            // 5. Merge unique candidate books
            var booksByID: [PersistentIdentifier: Book] = [:]
            for book in predicateBooks {
                booksByID[book.persistentModelID] = book
            }
            for author in matchingAuthors {
                for book in author.books {
                    booksByID[book.persistentModelID] = book
                }
            }
            for tag in matchingTags {
                for book in tag.books {
                    booksByID[book.persistentModelID] = book
                }
            }
            for note in matchingNotes {
                if let book = note.book {
                    booksByID[book.persistentModelID] = book
                }
            }

            // 6. Apply status/rating/tag filters and build match reasons
            let candidates = booksByID.values.filter { book in
                if let statusFilter, book.status != statusFilter { return false }
                if let ratingFilter, book.rating != ratingFilter { return false }
                if !tagFilters.isEmpty {
                    let bookTagIDs = Set(book.tags.map(\.persistentModelID))
                    let filterIDs = Set(tagFilters.map(\.persistentModelID))
                    switch tagFilterMode {
                    case .and:
                        if !filterIDs.isSubset(of: bookTagIDs) { return false }
                    case .or:
                        if filterIDs.isDisjoint(with: bookTagIDs) { return false }
                    }
                }
                return true
            }

            var results = searchService.filterByRelationships(
                books: Array(candidates),
                searchText: searchText
            )

            // 7. Sort in memory
            results.sort { a, b in
                sortCompare(a.book, b.book)
            }

            searchResults = results
            hasMore = false
            error = nil
        } catch {
            self.error = PersistenceError.fetchFailed(underlying: error).localizedDescription
        }
    }

    private func sortCompare(_ a: Book, _ b: Book) -> Bool {
        switch sortOption {
        case .title:
            let result = a.title.localizedCaseInsensitiveCompare(b.title)
            return sortAscending ? result == .orderedAscending : result == .orderedDescending
        case .dateAdded:
            return sortAscending ? a.dateAdded < b.dateAdded : a.dateAdded > b.dateAdded
        case .rating:
            let ar = a.rating ?? 0, br = b.rating ?? 0
            return sortAscending ? ar < br : ar > br
        case .author:
            let result = a.authorNames.localizedCaseInsensitiveCompare(b.authorNames)
            return sortAscending ? result == .orderedAscending : result == .orderedDescending
        }
    }
}
