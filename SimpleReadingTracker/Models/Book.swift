import Foundation
import SwiftData

@Model
final class Book {
    var title: String
    var isbn: String?
    var coverImageURL: String?
    @Attribute(.externalStorage) var coverImageData: Data?
    var publisher: String?
    var publishedDate: String?
    var bookDescription: String?
    var pageCount: Int?
    var statusRawValue: String
    var rating: Int?
    var dateAdded: Date
    var dateStarted: Date?
    var dateFinished: Date?

    @Relationship(deleteRule: .cascade, inverse: \Note.book)
    var notes: [Note]

    @Relationship(inverse: \Author.books)
    var authors: [Author]

    @Relationship(inverse: \Tag.books)
    var tags: [Tag]

    var status: ReadingStatus {
        get { ReadingStatus(rawValue: statusRawValue) ?? .toRead }
        set { statusRawValue = newValue.rawValue }
    }

    var authorNames: String {
        authors.map(\.name).joined(separator: ", ")
    }

    init(
        title: String,
        isbn: String? = nil,
        coverImageURL: String? = nil,
        coverImageData: Data? = nil,
        publisher: String? = nil,
        publishedDate: String? = nil,
        bookDescription: String? = nil,
        pageCount: Int? = nil,
        status: ReadingStatus = .toRead,
        rating: Int? = nil,
        dateAdded: Date = .now,
        dateStarted: Date? = nil,
        dateFinished: Date? = nil
    ) {
        self.title = title
        self.isbn = isbn
        self.coverImageURL = coverImageURL
        self.coverImageData = coverImageData
        self.publisher = publisher
        self.publishedDate = publishedDate
        self.bookDescription = bookDescription
        self.pageCount = pageCount
        self.statusRawValue = status.rawValue
        self.rating = rating
        self.dateAdded = dateAdded
        self.dateStarted = dateStarted
        self.dateFinished = dateFinished
        self.notes = []
        self.authors = []
        self.tags = []
    }
}
