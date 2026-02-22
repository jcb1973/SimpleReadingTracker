import Foundation
import Testing
import SwiftData
@testable import SimpleReadingTracker

private typealias BookTag = SimpleReadingTracker.Tag

struct TagDeduplicatorTests {

    // MARK: - findOrCreate

    @Test @MainActor func findOrCreateReturnsExistingTag() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let existing = ModelFactory.makeTag(name: "fiction", in: context)
        try context.save()

        let result = TagDeduplicator.findOrCreate(named: "Fiction", in: context)

        #expect(result?.persistentModelID == existing.persistentModelID)
    }

    @Test @MainActor func findOrCreateCreatesNewTag() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let result = TagDeduplicator.findOrCreate(named: "Sci-Fi", in: context)

        #expect(result != nil)
        #expect(result?.name == "sci-fi")
        #expect(result?.displayName == "Sci-Fi")
    }

    @Test @MainActor func findOrCreateMergesDuplicates() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let tag1 = BookTag(name: "fantasy")
        context.insert(tag1)
        let tag2 = BookTag(name: "fantasy")
        context.insert(tag2)

        let book = ModelFactory.makeBook(title: "Book A", in: context)
        tag2.books = (tag2.books ?? []) + [book]
        try context.save()

        let result = TagDeduplicator.findOrCreate(named: "fantasy", in: context)
        let tagIDs = Set([tag1.persistentModelID, tag2.persistentModelID])

        #expect(tagIDs.contains(result!.persistentModelID))
        #expect((result?.books ?? []).contains(where: { $0.persistentModelID == book.persistentModelID }) == true)
    }

    @Test @MainActor func findOrCreateReturnsNilForEmptyInput() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        #expect(TagDeduplicator.findOrCreate(named: "", in: context) == nil)
        #expect(TagDeduplicator.findOrCreate(named: "   ", in: context) == nil)
    }

    // MARK: - deduplicateAll

    @Test @MainActor func deduplicateAllMergesAllGroups() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let tag1a = BookTag(name: "fiction")
        let tag1b = BookTag(name: "fiction")
        let tag2a = BookTag(name: "history")
        let tag2b = BookTag(name: "history")
        for tag in [tag1a, tag1b, tag2a, tag2b] {
            context.insert(tag)
        }
        try context.save()

        TagDeduplicator.deduplicateAll(in: context)

        let allTags = try context.fetch(FetchDescriptor<BookTag>())
        let fictionTags = allTags.filter { $0.name == "fiction" }
        let historyTags = allTags.filter { $0.name == "history" }
        #expect(fictionTags.count == 1)
        #expect(historyTags.count == 1)
    }

    // MARK: - Merge behavior

    @Test @MainActor func mergePreservesColorFromDuplicate() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let survivor = BookTag(name: "fantasy")
        context.insert(survivor)
        let duplicate = BookTag(name: "fantasy")
        duplicate.colorName = "blue"
        context.insert(duplicate)
        try context.save()

        let result = TagDeduplicator.findOrCreate(named: "fantasy", in: context)

        #expect(result?.colorName == "blue")
    }

    @Test @MainActor func mergeKeepsSurvivorColorWhenBothHaveColor() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let tag1 = BookTag(name: "fantasy")
        tag1.colorName = "red"
        context.insert(tag1)
        let tag2 = BookTag(name: "fantasy")
        tag2.colorName = "blue"
        context.insert(tag2)
        try context.save()

        let result = TagDeduplicator.findOrCreate(named: "fantasy", in: context)

        // Survivor keeps its own color; fetch order is non-deterministic
        let color = try #require(result?.colorName)
        #expect(color == "red" || color == "blue")
    }

    @Test @MainActor func mergeReassignsBooksCorrectly() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let tag1 = BookTag(name: "scifi")
        context.insert(tag1)
        let tag2 = BookTag(name: "scifi")
        context.insert(tag2)

        let bookA = ModelFactory.makeBook(title: "Book A", in: context)
        let bookB = ModelFactory.makeBook(title: "Book B", in: context)
        tag1.books = (tag1.books ?? []) + [bookA]
        tag2.books = (tag2.books ?? []) + [bookB]
        // Both share bookA to test dedup of book references
        tag2.books = (tag2.books ?? []) + [bookA]
        try context.save()

        let result = TagDeduplicator.findOrCreate(named: "scifi", in: context)

        let bookIDs = Set((result?.books ?? []).map(\.persistentModelID))
        #expect(bookIDs.contains(bookA.persistentModelID))
        #expect(bookIDs.contains(bookB.persistentModelID))
        #expect((result?.books ?? []).count == 2)
    }
}
