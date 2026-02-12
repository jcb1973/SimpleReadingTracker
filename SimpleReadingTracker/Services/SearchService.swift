import Foundation
import SwiftData

enum SortOption: String, CaseIterable, Identifiable {
    case title
    case dateAdded
    case rating
    case author

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .title: "Title"
        case .dateAdded: "Date Added"
        case .rating: "Rating"
        case .author: "Author"
        }
    }
}

enum MatchReason: Equatable {
    case title
    case author(String)
    case tag(String)
    case note
    case isbn
}

struct SearchResult {
    let book: Book
    let matchReasons: [MatchReason]
}

struct SearchService {
    func buildPredicate(
        searchText: String,
        statusFilter: ReadingStatus?,
        ratingFilter: Int? = nil
    ) -> Predicate<Book> {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let hasSearch = !trimmed.isEmpty
        let statusRaw: String? = statusFilter?.rawValue
        let minRating: Int? = ratingFilter

        return #Predicate<Book> { book in
            (!hasSearch || (
                book.title.localizedStandardContains(trimmed) ||
                book.isbn?.localizedStandardContains(trimmed) == true
            )) &&
            (statusRaw == nil || book.statusRawValue == statusRaw!) &&
            (minRating == nil || book.rating == minRating!)
        }
    }

    func buildSortDescriptors(option: SortOption, ascending: Bool) -> [SortDescriptor<Book>] {
        switch option {
        case .title:
            [SortDescriptor(\.title, order: ascending ? .forward : .reverse)]
        case .dateAdded:
            [SortDescriptor(\.dateAdded, order: ascending ? .forward : .reverse)]
        case .rating:
            [SortDescriptor(\.rating, order: ascending ? .forward : .reverse)]
        case .author:
            [SortDescriptor(\.title, order: ascending ? .forward : .reverse)]
        }
    }

    func filterByRelationships(
        books: [Book],
        searchText: String
    ) -> [SearchResult] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            return books.map { SearchResult(book: $0, matchReasons: []) }
        }

        return books.compactMap { book in
            var reasons: [MatchReason] = []

            if book.title.localizedCaseInsensitiveContains(trimmed) {
                reasons.append(.title)
            }

            if let isbn = book.isbn, isbn.localizedCaseInsensitiveContains(trimmed) {
                reasons.append(.isbn)
            }

            for author in book.authors where author.name.localizedCaseInsensitiveContains(trimmed) {
                reasons.append(.author(author.name))
            }

            for tag in book.tags where tag.name.localizedCaseInsensitiveContains(trimmed) ||
                tag.displayName.localizedCaseInsensitiveContains(trimmed) {
                reasons.append(.tag(tag.displayName))
            }

            for note in book.notes where note.content.localizedCaseInsensitiveContains(trimmed) {
                reasons.append(.note)
                break
            }

            guard !reasons.isEmpty else { return nil }
            return SearchResult(book: book, matchReasons: reasons)
        }
    }
}
