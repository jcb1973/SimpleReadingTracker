import CoreGraphics
import Foundation
import ImageIO
import Observation
import SwiftData
import UniformTypeIdentifiers

enum BookFormMode {
    case add
    case edit(Book)
}

@Observable
final class BookFormViewModel {
    private let modelContext: ModelContext
    private let lookupService: any BookLookupService
    let mode: BookFormMode

    var title = ""
    var isbn = ""
    var authorNames: [String] = [""]
    var tagNames: [String] = [""]
    var publisher = ""
    var publishedDate = ""
    var bookDescription = ""
    var pageCountString = ""
    var status: ReadingStatus = .toRead
    var rating: Int?
    var coverImageURL = ""
    var selectedImageData: Data?

    var isLookingUp = false
    private(set) var lookupError: String?
    private(set) var error: String?

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var navigationTitle: String {
        switch mode {
        case .add: "Add Book"
        case .edit: "Edit Book"
        }
    }

    private(set) var authorSuggestions: [Author] = []
    private(set) var tagSuggestions: [Tag] = []

    init(
        mode: BookFormMode,
        modelContext: ModelContext,
        lookupService: any BookLookupService = RemoteBookLookupService()
    ) {
        self.mode = mode
        self.modelContext = modelContext
        self.lookupService = lookupService

        if case .edit(let book) = mode {
            populateFromBook(book)
        }
    }

    private func populateFromBook(_ book: Book) {
        title = book.title
        isbn = book.isbn ?? ""
        authorNames = book.authors.map(\.name)
        if authorNames.isEmpty { authorNames = [""] }
        tagNames = book.tags.map(\.displayName)
        if tagNames.isEmpty { tagNames = [""] }
        publisher = book.publisher ?? ""
        publishedDate = book.publishedDate ?? ""
        bookDescription = book.bookDescription ?? ""
        pageCountString = book.pageCount.map(String.init) ?? ""
        status = book.status
        rating = book.rating
        coverImageURL = book.coverImageURL ?? ""
        selectedImageData = book.coverImageData
    }

    func lookupISBN() async {
        let trimmedISBN = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedISBN.isEmpty else { return }

        isLookingUp = true
        lookupError = nil
        do {
            let result = try await lookupService.lookupISBN(trimmedISBN)
            title = result.title
            if !result.authors.isEmpty {
                authorNames = result.authors
            }
            if let url = result.coverImageURL { coverImageURL = url }
            if let pub = result.publisher { publisher = pub }
            if let date = result.publishedDate { publishedDate = date }
            if let desc = result.description { bookDescription = desc }
            if let pages = result.pageCount { pageCountString = String(pages) }
        } catch {
            lookupError = error.localizedDescription
        }
        isLookingUp = false
    }

    func save() {
        switch mode {
        case .add:
            createBook()
        case .edit(let book):
            updateBook(book)
        }
    }

    private func createBook() {
        let book = Book(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            isbn: isbn.isEmpty ? nil : isbn,
            coverImageURL: coverImageURL.isEmpty ? nil : coverImageURL,
            coverImageData: selectedImageData,
            publisher: publisher.isEmpty ? nil : publisher,
            publishedDate: publishedDate.isEmpty ? nil : publishedDate,
            bookDescription: bookDescription.isEmpty ? nil : bookDescription,
            pageCount: Int(pageCountString),
            status: status,
            rating: rating
        )

        modelContext.insert(book)
        attachAuthors(to: book)
        attachTags(to: book)

        do {
            try modelContext.save()
            error = nil
        } catch {
            self.error = PersistenceError.saveFailed(underlying: error).localizedDescription
        }
    }

    private func updateBook(_ book: Book) {
        book.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        book.isbn = isbn.isEmpty ? nil : isbn
        book.coverImageURL = coverImageURL.isEmpty ? nil : coverImageURL
        book.publisher = publisher.isEmpty ? nil : publisher
        book.publishedDate = publishedDate.isEmpty ? nil : publishedDate
        book.bookDescription = bookDescription.isEmpty ? nil : bookDescription
        book.pageCount = Int(pageCountString)
        book.status = status
        book.rating = rating
        book.coverImageData = selectedImageData

        book.authors.removeAll()
        book.tags.removeAll()
        attachAuthors(to: book)
        attachTags(to: book)

        do {
            try modelContext.save()
            error = nil
        } catch {
            self.error = PersistenceError.saveFailed(underlying: error).localizedDescription
        }
    }

    private func attachAuthors(to book: Book) {
        for name in authorNames {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let existing = findAuthor(named: trimmed)
            let author = existing ?? Author(name: trimmed)
            if existing == nil {
                modelContext.insert(author)
            }
            book.authors.append(author)
        }
    }

    private func attachTags(to book: Book) {
        for name in tagNames {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let lowered = trimmed.lowercased()
            let existing = findTag(named: lowered)
            let tag = existing ?? Tag(name: trimmed)
            if existing == nil {
                modelContext.insert(tag)
            }
            book.tags.append(tag)
        }
    }

    func addAuthorField() {
        authorNames.append("")
    }

    func removeAuthorField(at index: Int) {
        guard authorNames.count > 1 else { return }
        authorNames.remove(at: index)
    }

    func addTagField() {
        tagNames.append("")
    }

    func removeTagField(at index: Int) {
        guard tagNames.count > 1 else { return }
        tagNames.remove(at: index)
    }

    func fetchAuthorSuggestions(for query: String) {
        guard !query.isEmpty else {
            authorSuggestions = []
            return
        }
        let descriptor = FetchDescriptor<Author>()
        let allAuthors = (try? modelContext.fetch(descriptor)) ?? []
        authorSuggestions = allAuthors.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    func fetchTagSuggestions(for query: String) {
        guard !query.isEmpty else {
            tagSuggestions = []
            return
        }
        let descriptor = FetchDescriptor<Tag>()
        let allTags = (try? modelContext.fetch(descriptor)) ?? []
        tagSuggestions = allTags.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.displayName.localizedCaseInsensitiveContains(query)
        }
    }

    private func findAuthor(named name: String) -> Author? {
        let descriptor = FetchDescriptor<Author>()
        let authors = (try? modelContext.fetch(descriptor)) ?? []
        return authors.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }
    }

    private func findTag(named lowercaseName: String) -> Tag? {
        let descriptor = FetchDescriptor<Tag>()
        let tags = (try? modelContext.fetch(descriptor)) ?? []
        return tags.first { $0.name == lowercaseName }
    }

    func processSelectedImage(_ data: Data) {
        selectedImageData = Self.compressImage(data, maxWidth: 600, quality: 0.7)
    }

    func removeSelectedImage() {
        selectedImageData = nil
    }

    static func compressImage(_ data: Data, maxWidth: CGFloat, quality: CGFloat) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)

        let scale: CGFloat
        if originalWidth > maxWidth {
            scale = maxWidth / originalWidth
        } else {
            scale = 1.0
        }

        let newWidth = Int(originalWidth * scale)
        let newHeight = Int(originalHeight * scale)

        guard let colorSpace = cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                  data: nil,
                  width: newWidth,
                  height: newHeight,
                  bitsPerComponent: 8,
                  bytesPerRow: 0,
                  space: colorSpace,
                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            return nil
        }

        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        guard let resizedImage = context.makeImage() else { return nil }

        let destData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            destData as CFMutableData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        CGImageDestinationAddImage(destination, resizedImage, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }

        return destData as Data
    }
}
