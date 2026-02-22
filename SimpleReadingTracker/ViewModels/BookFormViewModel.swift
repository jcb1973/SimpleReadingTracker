import Foundation
import Observation
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

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
        lookupService: any BookLookupService = CachingBookLookupService()
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
        authorNames = (book.authors ?? []).map(\.name)
        if authorNames.isEmpty { authorNames = [""] }
        tagNames = (book.tags ?? []).map(\.displayName)
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
            if let url = result.coverImageURL {
                coverImageURL = url
                #if canImport(UIKit)
                await downloadCoverImage(from: url)
                #endif
            }
            if let pub = result.publisher { publisher = pub }
            if let date = result.publishedDate { publishedDate = date }
            if let desc = result.description { bookDescription = desc }
            if let pages = result.pageCount { pageCountString = String(pages) }
        } catch {
            lookupError = error.localizedDescription
        }
        isLookingUp = false
    }

    #if canImport(UIKit)
    func downloadCoverImage(from urlString: String) async {
        guard selectedImageData == nil,
              let url = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let compressed = Self.compressImage(data, maxWidth: 600, quality: 0.7) {
                selectedImageData = compressed
            }
        } catch {
            // Cover download failed — user can still add one manually
        }
    }
    #endif

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

        book.authors?.removeAll()
        book.tags?.removeAll()
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
            book.authors = (book.authors ?? []) + [author]
        }
    }

    private func attachTags(to book: Book) {
        for name in tagNames {
            guard let tag = TagDeduplicator.findOrCreate(named: name, in: modelContext) else { continue }
            book.tags = (book.tags ?? []) + [tag]
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

    #if canImport(UIKit)
    func processSelectedImage(_ data: Data) {
        selectedImageData = Self.compressImage(data, maxWidth: 600, quality: 0.7)
    }
    #endif

    func removeSelectedImage() {
        selectedImageData = nil
    }

    #if canImport(UIKit)
    static func compressImage(_ data: Data, maxWidth: CGFloat, quality: CGFloat) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let originalSize = image.size
        let scale: CGFloat
        if originalSize.width > maxWidth {
            scale = maxWidth / originalSize.width
        } else {
            scale = 1.0
        }

        let newSize = CGSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedData = renderer.jpegData(withCompressionQuality: quality) { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return resizedData
    }
    #endif
}
