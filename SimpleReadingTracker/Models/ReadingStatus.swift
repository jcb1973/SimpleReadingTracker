import Foundation

enum ReadingStatus: String, Codable, CaseIterable, Identifiable {
    case toRead = "toRead"
    case reading = "reading"
    case read = "read"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .toRead: "To Read"
        case .reading: "Reading"
        case .read: "Read"
        }
    }

    var systemImage: String {
        switch self {
        case .toRead: "bookmark"
        case .reading: "book.fill"
        case .read: "checkmark.circle.fill"
        }
    }

    var next: ReadingStatus {
        switch self {
        case .toRead: .reading
        case .reading: .read
        case .read: .toRead
        }
    }
}
