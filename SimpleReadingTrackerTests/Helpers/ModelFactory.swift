import Foundation
import SwiftData
@testable import SimpleReadingTracker

enum ModelFactory {
    @MainActor
    static func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: Book.self, Author.self, Note.self, Tag.self,
            configurations: config
        )
    }

    @MainActor
    static func makeBook(
        title: String = "Test Book",
        isbn: String? = "9780123456789",
        coverImageData: Data? = nil,
        status: ReadingStatus = .toRead,
        rating: Int? = nil,
        in context: ModelContext
    ) -> Book {
        let book = Book(
            title: title,
            isbn: isbn,
            coverImageData: coverImageData,
            status: status,
            rating: rating
        )
        context.insert(book)
        return book
    }

    @MainActor
    static func makeAuthor(
        name: String = "Test Author",
        in context: ModelContext
    ) -> Author {
        let author = Author(name: name)
        context.insert(author)
        return author
    }

    @MainActor
    static func makeTag(
        name: String = "fiction",
        displayName: String? = nil,
        in context: ModelContext
    ) -> Tag {
        let tag = Tag(name: name, displayName: displayName)
        context.insert(tag)
        return tag
    }

    @MainActor
    static func makeNote(
        content: String = "A test note",
        book: Book,
        in context: ModelContext
    ) -> Note {
        let note = Note(content: content, book: book)
        context.insert(note)
        return note
    }
}
