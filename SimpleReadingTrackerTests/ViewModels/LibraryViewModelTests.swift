import Foundation
import Testing
import SwiftData
@testable import SimpleReadingTracker

struct LibraryViewModelTests {
    @Test @MainActor func fetchBooksReturnsAll() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let _ = ModelFactory.makeBook(title: "Book A", in: context)
        let _ = ModelFactory.makeBook(title: "Book B", in: context)
        try context.save()

        let vm = LibraryViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.books.count == 2)
    }

    @Test @MainActor func fetchBooksWithStatusFilter() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let _ = ModelFactory.makeBook(title: "Reading", status: .reading, in: context)
        let _ = ModelFactory.makeBook(title: "To Read", status: .toRead, in: context)
        try context.save()

        let vm = LibraryViewModel(modelContext: context)
        vm.statusFilter = .reading
        vm.fetchBooks()

        #expect(vm.books.count == 1)
        #expect(vm.books.first?.title == "Reading")
    }

    @Test @MainActor func deleteBookRemovesFromList() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Delete Me", in: context)
        try context.save()

        let vm = LibraryViewModel(modelContext: context)
        vm.fetchBooks()
        #expect(vm.books.count == 1)

        vm.deleteBook(id: book.persistentModelID)
        #expect(vm.books.isEmpty)
    }

    @Test @MainActor func updateStatusChangesBookStatus() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", status: .toRead, in: context)
        try context.save()

        let vm = LibraryViewModel(modelContext: context)
        vm.updateStatus(for: book, to: .reading)

        #expect(book.status == .reading)
        #expect(book.dateStarted != nil)
    }

    @Test @MainActor func updateStatusToReadSetsFinishDate() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", status: .reading, in: context)
        try context.save()

        let vm = LibraryViewModel(modelContext: context)
        vm.updateStatus(for: book, to: .read)

        #expect(book.status == .read)
        #expect(book.dateFinished != nil)
    }

    @Test @MainActor func searchTextFiltersBooks() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let _ = ModelFactory.makeBook(title: "Swift Programming", in: context)
        let _ = ModelFactory.makeBook(title: "Cooking Recipes", in: context)
        try context.save()

        let vm = LibraryViewModel(modelContext: context)
        vm.searchText = "swift"
        vm.fetchBooks()

        #expect(vm.books.count == 1)
        #expect(vm.books.first?.title == "Swift Programming")
    }
}
