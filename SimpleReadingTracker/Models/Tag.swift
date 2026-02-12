import Foundation
import SwiftData

@Model
final class Tag {
    #Unique<Tag>([\.name])

    var name: String
    var displayName: String
    var books: [Book]

    init(name: String, displayName: String? = nil) {
        self.name = name.lowercased()
        self.displayName = displayName ?? name
        self.books = []
    }
}
