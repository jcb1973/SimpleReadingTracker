import Foundation
import SwiftData

@Model
final class Note {
    var content: String
    var createdAt: Date
    var book: Book?

    init(content: String, book: Book) {
        self.content = content
        self.createdAt = .now
        self.book = book
    }
}
