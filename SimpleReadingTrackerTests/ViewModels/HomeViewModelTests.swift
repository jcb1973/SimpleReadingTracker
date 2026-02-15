import Foundation
import Testing
import SwiftData
@testable import SimpleReadingTracker

struct HomeViewModelTests {
    @Test @MainActor func fetchBooksPopulatesCurrentlyReading() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Reading Book", status: .reading, in: context)
        book.dateStarted = .now
        try context.save()

        let vm = HomeViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.currentlyReading.count == 1)
        #expect(vm.currentlyReading.first?.title == "Reading Book")
    }

    @Test @MainActor func fetchBooksExcludesUnrelatedStatuses() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let _ = ModelFactory.makeBook(title: "Want to Read", status: .toRead, in: context)
        try context.save()

        let vm = HomeViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.currentlyReading.isEmpty)
    }

    @Test @MainActor func fetchBooksPopulatesStatusCounts() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let _ = ModelFactory.makeBook(title: "Book 1", status: .toRead, in: context)
        let _ = ModelFactory.makeBook(title: "Book 2", status: .reading, in: context)
        let _ = ModelFactory.makeBook(title: "Book 3", status: .read, in: context)
        try context.save()

        let vm = HomeViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.statusCounts[.toRead] == 1)
        #expect(vm.statusCounts[.reading] == 1)
        #expect(vm.statusCounts[.read] == 1)
    }

    @Test @MainActor func fetchBooksNoError() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = HomeViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.error == nil)
    }
}
