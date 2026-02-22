import Foundation
import SwiftData
#if canImport(SwiftUI)
import SwiftUI
#endif

@Model
final class Tag {
    var name: String = ""
    var displayName: String = ""
    var colorName: String?
    var books: [Book]?

    var tagColor: TagColor? {
        get { colorName.flatMap { TagColor(rawValue: $0) }?.canonical }
        set { colorName = newValue?.rawValue }
    }

    #if canImport(SwiftUI)
    var resolvedColor: Color {
        tagColor?.color ?? .accentColor
    }
    #endif

    init(name: String, displayName: String? = nil) {
        self.name = name.lowercased()
        self.displayName = displayName ?? name
        self.books = []
    }
}
