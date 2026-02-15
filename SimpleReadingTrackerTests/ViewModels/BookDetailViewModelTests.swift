import Foundation
import Testing
import SwiftData
@testable import SimpleReadingTracker

struct BookDetailViewModelTests {
    @Test @MainActor func updateStatusChangesBookStatus() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", status: .toRead, in: context)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.updateStatus(.reading)

        #expect(book.status == .reading)
        #expect(book.dateStarted != nil)
    }

    @Test @MainActor func updateRatingSetsRating() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", in: context)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.updateRating(4)

        #expect(book.rating == 4)
    }

    @Test @MainActor func clearRating() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", rating: 3, in: context)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.updateRating(nil)

        #expect(book.rating == nil)
    }

    @Test @MainActor func cycleStatusRotatesCorrectly() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", status: .toRead, in: context)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)

        vm.cycleStatus()
        #expect(book.status == .reading)

        vm.cycleStatus()
        #expect(book.status == .read)

        vm.cycleStatus()
        #expect(book.status == .toRead)
    }

    @Test @MainActor func markAsReadSetsDate() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", status: .reading, in: context)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.updateStatus(.read)

        #expect(book.dateFinished != nil)
    }
}
