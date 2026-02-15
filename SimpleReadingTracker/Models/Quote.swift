import Foundation
import SwiftData

@Model
final class Quote {
    var text: String
    var comment: String?
    var pageNumber: Int?
    var createdAt: Date
    var book: Book?

    init(text: String, comment: String? = nil, pageNumber: Int? = nil, book: Book) {
        self.text = text
        self.comment = comment
        self.pageNumber = pageNumber
        self.createdAt = .now
        self.book = book
    }
}
