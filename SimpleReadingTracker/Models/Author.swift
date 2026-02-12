import Foundation
import SwiftData

@Model
final class Author {
    var name: String
    var books: [Book]

    init(name: String) {
        self.name = name
        self.books = []
    }
}
