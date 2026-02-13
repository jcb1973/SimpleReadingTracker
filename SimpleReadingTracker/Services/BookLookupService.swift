import Foundation

nonisolated struct BookLookupResult: Sendable, Codable {
    let title: String
    let authors: [String]
    let isbn: String?
    let coverImageURL: String?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
}

protocol BookLookupService: Sendable {
    func lookupISBN(_ isbn: String) async throws -> BookLookupResult
}

struct RemoteBookLookupService: BookLookupService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func lookupISBN(_ isbn: String) async throws -> BookLookupResult {
        let cleanISBN = isbn.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
        guard cleanISBN.count == 10 || cleanISBN.count == 13 else {
            throw BookLookupError.invalidISBN
        }

        if let result = try? await lookupOpenLibrary(isbn: cleanISBN) {
            return result
        }
        return try await lookupGoogleBooks(isbn: cleanISBN)
    }

    // MARK: - Open Library

    private func lookupOpenLibrary(isbn: String) async throws -> BookLookupResult {
        guard let url = URL(string: "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&format=json&jscmd=data") else {
            throw BookLookupError.invalidISBN
        }

        let (data, _) = try await performRequest(url: url)

        let decoded = try JSONDecoder().decode([String: OpenLibraryBook].self, from: data)
        guard let book = decoded["ISBN:\(isbn)"] else {
            throw BookLookupError.notFound
        }

        return BookLookupResult(
            title: book.title,
            authors: book.authors?.map(\.name) ?? [],
            isbn: isbn,
            coverImageURL: book.cover?.medium,
            publisher: book.publishers?.first?.name,
            publishedDate: book.publishDate,
            description: nil,
            pageCount: book.numberOfPages
        )
    }

    // MARK: - Google Books

    private func lookupGoogleBooks(isbn: String) async throws -> BookLookupResult {
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)") else {
            throw BookLookupError.invalidISBN
        }

        let (data, _) = try await performRequest(url: url)

        let decoded: GoogleBooksResponse
        do {
            decoded = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
        } catch {
            throw BookLookupError.decodingError(underlying: error)
        }

        guard let item = decoded.items?.first else {
            throw BookLookupError.notFound
        }

        let info = item.volumeInfo
        let coverURL = info.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://")

        return BookLookupResult(
            title: info.title,
            authors: info.authors ?? [],
            isbn: isbn,
            coverImageURL: coverURL,
            publisher: info.publisher,
            publishedDate: info.publishedDate,
            description: info.description,
            pageCount: info.pageCount
        )
    }

    private func performRequest(url: URL) async throws -> (Data, URLResponse) {
        let result: (Data, URLResponse)
        do {
            result = try await session.data(from: url)
        } catch {
            throw BookLookupError.networkError(underlying: error)
        }
        if let httpResponse = result.1 as? HTTPURLResponse, httpResponse.statusCode == 429 {
            throw BookLookupError.rateLimited
        }
        return result
    }
}

// MARK: - Open Library DTOs

private struct OpenLibraryBook: Decodable {
    let title: String
    let authors: [OpenLibraryAuthor]?
    let publishers: [OpenLibraryPublisher]?
    let numberOfPages: Int?
    let publishDate: String?
    let cover: OpenLibraryCover?

    enum CodingKeys: String, CodingKey {
        case title, authors, publishers, cover
        case numberOfPages = "number_of_pages"
        case publishDate = "publish_date"
    }
}

private struct OpenLibraryAuthor: Decodable {
    let name: String
}

private struct OpenLibraryPublisher: Decodable {
    let name: String
}

private struct OpenLibraryCover: Decodable {
    let medium: String?
}

// MARK: - Google Books DTOs

private struct GoogleBooksResponse: Decodable {
    let items: [GoogleBooksItem]?
}

private struct GoogleBooksItem: Decodable {
    let volumeInfo: GoogleBooksVolumeInfo
}

private struct GoogleBooksVolumeInfo: Decodable {
    let title: String
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let imageLinks: GoogleBooksImageLinks?
}

private struct GoogleBooksImageLinks: Decodable {
    let thumbnail: String?
}
