import Foundation

enum BookLookupError: Error, LocalizedError {
    case invalidISBN
    case networkError(underlying: Error)
    case notFound
    case decodingError(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidISBN:
            "The ISBN provided is not valid."
        case .networkError(let underlying):
            "Network error: \(underlying.localizedDescription)"
        case .notFound:
            "No book found for this ISBN."
        case .decodingError(let underlying):
            "Failed to parse book data: \(underlying.localizedDescription)"
        }
    }
}

enum PersistenceError: Error, LocalizedError {
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case fetchFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let underlying):
            "Failed to save: \(underlying.localizedDescription)"
        case .deleteFailed(let underlying):
            "Failed to delete: \(underlying.localizedDescription)"
        case .fetchFailed(let underlying):
            "Failed to fetch data: \(underlying.localizedDescription)"
        }
    }
}
