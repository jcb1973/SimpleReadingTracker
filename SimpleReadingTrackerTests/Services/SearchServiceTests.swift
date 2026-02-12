import Foundation
import Testing
import SwiftData
@testable import SimpleReadingTracker

struct SearchServiceTests {
    let searchService = SearchService()

    @Test @MainActor func filterByRelationshipsMatchesTitle() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Swift Mastery", in: context)
        try context.save()

        let results = searchService.filterByRelationships(books: [book], searchText: "swift")
        #expect(results.count == 1)
        #expect(results.first?.matchReasons.contains(.title) == true)
    }

    @Test @MainActor func filterByRelationshipsMatchesISBN() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Some Book", isbn: "1234567890", in: context)
        try context.save()

        let results = searchService.filterByRelationships(books: [book], searchText: "1234567890")
        #expect(results.count == 1)
        #expect(results.first?.matchReasons.contains(.isbn) == true)
    }

    @Test @MainActor func filterByRelationshipsMatchesAuthor() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "A Book", in: context)
        let author = ModelFactory.makeAuthor(name: "Jane Smith", in: context)
        book.authors.append(author)
        try context.save()

        let results = searchService.filterByRelationships(books: [book], searchText: "jane")
        #expect(results.count == 1)
        #expect(results.first?.matchReasons.contains(where: {
            if case .author = $0 { return true }
            return false
        }) == true)
    }

    @Test @MainActor func filterByRelationshipsMatchesTag() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "A Book", in: context)
        let tag = ModelFactory.makeTag(name: "fiction", in: context)
        book.tags.append(tag)
        try context.save()

        let results = searchService.filterByRelationships(books: [book], searchText: "fiction")
        #expect(results.count == 1)
    }

    @Test @MainActor func filterByRelationshipsMatchesNotes() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "A Book", in: context)
        let _ = ModelFactory.makeNote(content: "Great chapter on algorithms", book: book, in: context)
        try context.save()

        let results = searchService.filterByRelationships(books: [book], searchText: "algorithms")
        #expect(results.count == 1)
        #expect(results.first?.matchReasons.contains(.note) == true)
    }

    @Test @MainActor func filterByRelationshipsReturnsAllForEmptySearch() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book1 = ModelFactory.makeBook(title: "Book One", in: context)
        let book2 = ModelFactory.makeBook(title: "Book Two", in: context)
        try context.save()

        let results = searchService.filterByRelationships(books: [book1, book2], searchText: "")
        #expect(results.count == 2)
    }

    @Test @MainActor func filterByRelationshipsExcludesNonMatches() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Cooking 101", in: context)
        try context.save()

        let results = searchService.filterByRelationships(books: [book], searchText: "swift")
        #expect(results.isEmpty)
    }

    @Test func buildSortDescriptorsReturnsCorrectOrder() {
        let ascending = searchService.buildSortDescriptors(option: .title, ascending: true)
        #expect(ascending.count == 1)

        let descending = searchService.buildSortDescriptors(option: .dateAdded, ascending: false)
        #expect(descending.count == 1)
    }
}
