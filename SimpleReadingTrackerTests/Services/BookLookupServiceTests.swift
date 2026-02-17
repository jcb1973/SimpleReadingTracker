import Testing
import Foundation
@testable import SimpleReadingTracker

@Suite(.serialized)
struct BookLookupServiceTests {
    // MARK: - Mock URL Protocol

    private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
        nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            guard let handler = Self.requestHandler else {
                client?.urlProtocolDidFinishLoading(self)
                return
            }
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() {}
    }

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    // MARK: - Tests

    @Test func invalidISBNThrows() async {
        let service = RemoteBookLookupService(session: makeSession())
        await #expect(throws: BookLookupError.self) {
            _ = try await service.lookupISBN("123")
        }
    }

    @Test func googleBooksLookupSuccess() async throws {
        let googleJSON = """
        {
          "items": [{
            "volumeInfo": {
              "title": "Swift Programming",
              "authors": ["Apple Inc."],
              "publisher": "Apple",
              "publishedDate": "2024",
              "description": "A great book",
              "pageCount": 400,
              "imageLinks": { "thumbnail": "https://example.com/cover.jpg" }
            }
          }]
        }
        """

        MockURLProtocol.requestHandler = { request in
            let url = request.url!
            if url.host == "openlibrary.org" {
                let data = "{}".data(using: .utf8)!
                let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            let data = googleJSON.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let service = RemoteBookLookupService(session: makeSession())
        let result = try await service.lookupISBN("9780123456789")

        #expect(result.title == "Swift Programming")
        #expect(result.authors == ["Apple Inc."])
        #expect(result.publisher == "Apple")
        #expect(result.pageCount == 400)
    }

    @Test func notFoundThrowsError() async {
        MockURLProtocol.requestHandler = { request in
            let url = request.url!
            let data = "{}".data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let service = RemoteBookLookupService(session: makeSession())
        await #expect(throws: BookLookupError.self) {
            _ = try await service.lookupISBN("9780123456789")
        }
    }

    @Test func openLibraryFallbackToGoogle() async throws {
        let openLibraryJSON = """
        {
          "ISBN:9780123456789": {
            "title": "OL Book",
            "authors": [{"name": "OL Author"}],
            "publishers": [{"name": "OL Press"}],
            "number_of_pages": 200,
            "publish_date": "2023",
            "cover": {"medium": "https://example.com/ol.jpg"}
          }
        }
        """

        MockURLProtocol.requestHandler = { request in
            let url = request.url!
            let data = openLibraryJSON.data(using: .utf8)!
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let service = RemoteBookLookupService(session: makeSession())
        let result = try await service.lookupISBN("9780123456789")

        #expect(result.title == "OL Book")
        #expect(result.authors == ["OL Author"])
        #expect(result.pageCount == 200)
    }
}
