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

    @Test @MainActor func addNoteAppendsToBook() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", in: context)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.noteText = "A great note"
        vm.addNote()

        #expect(book.notes.count == 1)
        #expect(book.notes.first?.content == "A great note")
        #expect(vm.noteText.isEmpty)
    }

    @Test @MainActor func addEmptyNoteDoesNothing() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", in: context)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.noteText = "   "
        vm.addNote()

        #expect(book.notes.isEmpty)
    }

    @Test @MainActor func deleteNoteRemovesFromBook() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", in: context)
        let note = ModelFactory.makeNote(content: "Delete me", book: book, in: context)
        book.notes.append(note)
        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        vm.deleteNote(note)

        #expect(book.notes.isEmpty)
    }

    @Test @MainActor func sortedNotesDescendingByDate() throws {
        let container = try ModelFactory.makeContainer()
        let context = container.mainContext
        let book = ModelFactory.makeBook(title: "Test", in: context)

        let note1 = Note(content: "First", book: book)
        note1.createdAt = Date(timeIntervalSince1970: 1000)
        context.insert(note1)
        book.notes.append(note1)

        let note2 = Note(content: "Second", book: book)
        note2.createdAt = Date(timeIntervalSince1970: 2000)
        context.insert(note2)
        book.notes.append(note2)

        try context.save()

        let vm = BookDetailViewModel(book: book, modelContext: context)
        let sorted = vm.sortedNotes

        #expect(sorted.first?.content == "Second")
        #expect(sorted.last?.content == "First")
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
