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

    @Test @MainActor func fetchBooksPopulatesRecentlyRead() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Finished Book", status: .read, in: context)
        book.dateFinished = .now
        try context.save()

        let vm = HomeViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.recentlyRead.count == 1)
        #expect(vm.recentlyRead.first?.title == "Finished Book")
    }

    @Test @MainActor func fetchBooksExcludesUnrelatedStatuses() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let _ = ModelFactory.makeBook(title: "Want to Read", status: .toRead, in: context)
        try context.save()

        let vm = HomeViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.currentlyReading.isEmpty)
        #expect(vm.recentlyRead.isEmpty)
    }

    @Test @MainActor func recentlyReadLimitedToFive() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        for i in 0..<8 {
            let book = ModelFactory.makeBook(title: "Book \(i)", status: .read, in: context)
            book.dateFinished = .now
        }
        try context.save()

        let vm = HomeViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.recentlyRead.count == 5)
    }

    @Test @MainActor func fetchBooksNoError() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext

        let vm = HomeViewModel(modelContext: context)
        vm.fetchBooks()

        #expect(vm.error == nil)
    }
}
