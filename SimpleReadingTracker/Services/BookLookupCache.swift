import Foundation

actor BookLookupCache {
    static let shared = BookLookupCache()

    private let directory: URL
    private var memoryCache: [String: BookLookupResult] = [:]

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        directory = caches.appendingPathComponent("ISBNLookups", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func lookup(_ isbn: String) -> BookLookupResult? {
        if let cached = memoryCache[isbn] {
            return cached
        }
        let fileURL = directory.appendingPathComponent("\(isbn).json")
        guard let result = CacheIO.read(from: fileURL) else {
            return nil
        }
        memoryCache[isbn] = result
        return result
    }

    func store(_ result: BookLookupResult, for isbn: String) {
        memoryCache[isbn] = result
        let fileURL = directory.appendingPathComponent("\(isbn).json")
        CacheIO.write(result, to: fileURL)
    }
}

// Nonisolated helper — keeps Codable operations outside actor isolation
nonisolated private enum CacheIO {
    static func read(from url: URL) -> BookLookupResult? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(BookLookupResult.self, from: data)
    }

    static func write(_ result: BookLookupResult, to url: URL) {
        guard let data = try? JSONEncoder().encode(result) else { return }
        try? data.write(to: url)
    }
}

struct CachingBookLookupService: BookLookupService {
    private let remote: RemoteBookLookupService
    private let cache: BookLookupCache

    init(
        remote: RemoteBookLookupService = RemoteBookLookupService(),
        cache: BookLookupCache = .shared
    ) {
        self.remote = remote
        self.cache = cache
    }

    func lookupISBN(_ isbn: String) async throws -> BookLookupResult {
        let cleanISBN = isbn.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)

        if let cached = await cache.lookup(cleanISBN) {
            return cached
        }

        let result = try await remote.lookupISBN(isbn)
        if let resultISBN = result.isbn {
            await cache.store(result, for: resultISBN)
        }
        return result
    }
}
