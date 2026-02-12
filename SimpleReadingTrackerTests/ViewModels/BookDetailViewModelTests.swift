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

    @Test @MainActor func saveNotesNowPersistsText() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", in: context)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.noteText = "My notes about this book"
        vm.saveNotesNow()

        #expect(book.userNotes == "My notes about this book")
    }

    @Test @MainActor func saveEmptyNotesClearsUserNotes() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", in: context)
        book.userNotes = "Old notes"
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.noteText = ""
        vm.saveNotesNow()

        #expect(book.userNotes == nil)
    }

    @Test @MainActor func initPopulatesNoteTextFromBook() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", in: context)
        book.userNotes = "Existing notes"
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)

        #expect(vm.noteText == "Existing notes")
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
