import Foundation
import SwiftData

@Model
final class Quote {
    var text: String
    var pageNumber: Int?
    var createdAt: Date
    var book: Book?

    init(text: String, pageNumber: Int? = nil, book: Book) {
        self.text = text
        self.pageNumber = pageNumber
        self.createdAt = .now
        self.book = book
    }
}
