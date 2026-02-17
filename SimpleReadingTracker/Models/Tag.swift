import Foundation
import SwiftData
import SwiftUI

@Model
final class Tag {
    #Unique<Tag>([\.name])

    var name: String
    var displayName: String
    var colorName: String?
    var books: [Book]

    var tagColor: TagColor? {
        get { colorName.flatMap { TagColor(rawValue: $0) }?.canonical }
        set { colorName = newValue?.rawValue }
    }

    var resolvedColor: Color {
        tagColor?.color ?? .accentColor
    }

    init(name: String, displayName: String? = nil) {
        self.name = name.lowercased()
        self.displayName = displayName ?? name
        self.books = []
    }
}
