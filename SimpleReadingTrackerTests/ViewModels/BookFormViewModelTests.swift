import Foundation
import Testing
import SwiftData
@testable import SimpleReadingTracker

struct BookFormViewModelTests {
    private struct MockLookupService: BookLookupService {
        var result: BookLookupResult?
        var error: BookLookupError?

        func lookupISBN(_ isbn: String) async throws -> BookLookupResult {
            if let error { throw error }
            guard let result else { throw BookLookupError.notFound }
            return result
        }
    }

    @Test @MainActor func isValidRequiresTitle() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = BookFormViewModel(mode: .add, modelContext: context)
        #expect(!vm.isValid)

        vm.title = "A Book"
        #expect(vm.isValid)
    }

    @Test @MainActor func isValidRejectsWhitespaceTitle() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = BookFormViewModel(mode: .add, modelContext: context)
        vm.title = "   "
        #expect(!vm.isValid)
    }

    @Test @MainActor func saveCreatesBook() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = BookFormViewModel(mode: .add, modelContext: context)
        vm.title = "New Book"
        vm.isbn = "9780123456789"
        vm.status = .toRead
        vm.save()

        let descriptor = FetchDescriptor<Book>()
        let books = try context.fetch(descriptor)
        #expect(books.count == 1)
        #expect(books.first?.title == "New Book")
        #expect(books.first?.isbn == "9780123456789")
    }

    @Test @MainActor func saveAttachesAuthors() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = BookFormViewModel(mode: .add, modelContext: context)
        vm.title = "Authored Book"
        vm.authorNames = ["Author One", "Author Two"]
        vm.save()

        let descriptor = FetchDescriptor<Book>()
        let books = try context.fetch(descriptor)
        #expect(books.first?.authors.count == 2)
    }

    @Test @MainActor func saveAttachesTags() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = BookFormViewModel(mode: .add, modelContext: context)
        vm.title = "Tagged Book"
        vm.tagNames = ["Fiction", "Sci-Fi"]
        vm.save()

        let descriptor = FetchDescriptor<Book>()
        let books = try context.fetch(descriptor)
        #expect(books.first?.tags.count == 2)
    }

    @Test @MainActor func editModePopulatesFields() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Existing", isbn: "1234", in: context)
        book.publisher = "Test Publisher"
        try context.save()

        let vm = BookFormViewModel(mode: .edit(book), modelContext: context)
        #expect(vm.title == "Existing")
        #expect(vm.isbn == "1234")
        #expect(vm.publisher == "Test Publisher")
    }

    @Test @MainActor func editModeSavesUpdates() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Old Title", in: context)
        try context.save()

        let vm = BookFormViewModel(mode: .edit(book), modelContext: context)
        vm.title = "New Title"
        vm.save()

        #expect(book.title == "New Title")
    }

    @Test @MainActor func lookupISBNPopulatesFields() async throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let mockResult = BookLookupResult(
            title: "Found Book",
            authors: ["Found Author"],
            isbn: "9780123456789",
            coverImageURL: "https://example.com/cover.jpg",
            publisher: "Found Publisher",
            publishedDate: "2024",
            description: "A found book",
            pageCount: 300
        )
        let mockService = MockLookupService(result: mockResult)

        let vm = BookFormViewModel(mode: .add, modelContext: context, lookupService: mockService)
        vm.isbn = "9780123456789"
        await vm.lookupISBN()

        #expect(vm.title == "Found Book")
        #expect(vm.authorNames == ["Found Author"])
        #expect(vm.publisher == "Found Publisher")
        #expect(vm.pageCountString == "300")
    }

    @Test @MainActor func lookupISBNSetsErrorOnFailure() async throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let mockService = MockLookupService(error: .notFound)

        let vm = BookFormViewModel(mode: .add, modelContext: context, lookupService: mockService)
        vm.isbn = "9780123456789"
        await vm.lookupISBN()

        #expect(vm.lookupError != nil)
    }

    @Test @MainActor func addAndRemoveAuthorFields() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = BookFormViewModel(mode: .add, modelContext: context)
        #expect(vm.authorNames.count == 1)

        vm.addAuthorField()
        #expect(vm.authorNames.count == 2)

        vm.removeAuthorField(at: 1)
        #expect(vm.authorNames.count == 1)
    }

    @Test @MainActor func cannotRemoveLastAuthorField() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = BookFormViewModel(mode: .add, modelContext: context)
        vm.removeAuthorField(at: 0)
        #expect(vm.authorNames.count == 1)
    }

    @Test @MainActor func emptyAuthorsSkipped() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = BookFormViewModel(mode: .add, modelContext: context)
        vm.title = "Book"
        vm.authorNames = ["", "  ", "Valid Author"]
        vm.save()

        let descriptor = FetchDescriptor<Book>()
        let books = try context.fetch(descriptor)
        #expect(books.first?.authors.count == 1)
    }

    @Test @MainActor func navigationTitleReflectsMode() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let addVM = BookFormViewModel(mode: .add, modelContext: context)
        #expect(addVM.navigationTitle == "Add Book")

        let book = ModelFactory.makeBook(title: "T", in: context)
        try context.save()
        let editVM = BookFormViewModel(mode: .edit(book), modelContext: context)
        #expect(editVM.navigationTitle == "Edit Book")
    }
}
