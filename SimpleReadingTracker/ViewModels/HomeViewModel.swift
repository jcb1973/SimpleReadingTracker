import Foundation
import Observation
import SwiftData

enum RecentEntry: Identifiable {
    case note(Note)
    case quote(Quote)

    var id: String {
        switch self {
        case .note(let n): "note-\(n.persistentModelID)"
        case .quote(let q): "quote-\(q.persistentModelID)"
        }
    }

    var date: Date {
        switch self {
        case .note(let n): n.createdAt
        case .quote(let q): q.createdAt
        }
    }

    var book: Book? {
        switch self {
        case .note(let n): n.book
        case .quote(let q): q.book
        }
    }

    var tab: NotesQuotesTab {
        switch self {
        case .note: .notes
        case .quote: .quotes
        }
    }
}

@Observable
final class HomeViewModel {
    private let modelContext: ModelContext

    private(set) var currentlyReading: [Book] = []
    private(set) var statusCounts: [ReadingStatus: Int] = [:]
    private(set) var ratingCounts: [Int: Int] = [:]
    private(set) var recentEntries: [RecentEntry] = []
    private(set) var error: String?
    var importResult: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchBooks() {
        do {
            let readingStatus = ReadingStatus.reading.rawValue
            let readingDescriptor = FetchDescriptor<Book>(
                predicate: #Predicate { $0.statusRawValue == readingStatus },
                sortBy: [SortDescriptor(\.dateStarted, order: .reverse)]
            )
            currentlyReading = try modelContext.fetch(readingDescriptor)

            var counts: [ReadingStatus: Int] = [:]
            for status in ReadingStatus.allCases {
                let raw = status.rawValue
                let desc = FetchDescriptor<Book>(
                    predicate: #Predicate { $0.statusRawValue == raw }
                )
                counts[status] = (try? modelContext.fetchCount(desc)) ?? 0
            }
            statusCounts = counts

            var ratings: [Int: Int] = [:]
            for star in 1...5 {
                let desc = FetchDescriptor<Book>(
                    predicate: #Predicate { $0.rating == star }
                )
                ratings[star] = (try? modelContext.fetchCount(desc)) ?? 0
            }
            ratingCounts = ratings

            fetchRecentEntries()

            error = nil
        } catch {
            self.error = PersistenceError.fetchFailed(underlying: error).localizedDescription
        }
    }

    // MARK: - CSV Export

    func exportCSV() -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        let fileDateFormatter = DateFormatter()
        fileDateFormatter.dateFormat = "yyyy-MM-dd"

        do {
            let allBooks = try modelContext.fetch(FetchDescriptor<Book>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]))

            var csv = "Title,Authors,Status,Rating,Tags,Pages,Publisher,Published Date,Date Added,Date Started,Date Finished,ISBN,Cover Image URL,Description,Notes,Quotes\n"

            for book in allBooks {
                let quotesText = book.quotes.map { quote in
                    var entry = quote.text
                    if let comment = quote.comment {
                        entry += " [Comment: \(comment)]"
                    }
                    if let page = quote.pageNumber {
                        entry += " (p. \(page))"
                    }
                    return entry
                }.joined(separator: "; ")

                let fields: [String] = [
                    csvEscape(book.title),
                    csvEscape(book.authorNames),
                    csvEscape(book.status.displayName),
                    book.rating.map(String.init) ?? "",
                    csvEscape(book.tags.map(\.displayName).joined(separator: "; ")),
                    book.pageCount.map(String.init) ?? "",
                    csvEscape(book.publisher ?? ""),
                    csvEscape(book.publishedDate ?? ""),
                    dateFormatter.string(from: book.dateAdded),
                    book.dateStarted.map { dateFormatter.string(from: $0) } ?? "",
                    book.dateFinished.map { dateFormatter.string(from: $0) } ?? "",
                    csvEscape(book.isbn ?? ""),
                    csvEscape(book.coverImageURL ?? ""),
                    csvEscape(book.bookDescription ?? ""),
                    csvEscape(book.notes.map(\.content).joined(separator: "; ")),
                    csvEscape(quotesText)
                ]
                csv += fields.joined(separator: ",") + "\n"
            }

            let fileName = "books-export-\(fileDateFormatter.string(from: .now)).csv"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            self.error = "Failed to create CSV file."
            return nil
        }
    }

    // MARK: - CSV Import

    func importCSV(from url: URL) throws -> Int {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        let content = try String(contentsOf: url, encoding: .utf8)
        let rows = parseCSVRows(content)
        guard rows.count > 1 else { return 0 }

        let headers = rows[0].map { $0.trimmingCharacters(in: .whitespaces) }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        let existingAuthors = (try? modelContext.fetch(FetchDescriptor<Author>())) ?? []
        var authorCache: [String: Author] = [:]
        for author in existingAuthors {
            authorCache[author.name.lowercased()] = author
        }

        var importedCount = 0

        for rowIndex in 1..<rows.count {
            let fields = rows[rowIndex]
            guard fields.count >= 1 else { continue }

            func value(for header: String) -> String? {
                guard let index = headers.firstIndex(of: header), index < fields.count else { return nil }
                let v = fields[index].trimmingCharacters(in: .whitespaces)
                return v.isEmpty ? nil : v
            }

            guard let title = value(for: "Title") else { continue }

            let status = ReadingStatus.allCases.first { $0.displayName == value(for: "Status") } ?? .toRead
            let rating = value(for: "Rating").flatMap(Int.init)
            let pageCount = value(for: "Pages").flatMap(Int.init)
            let publisher = value(for: "Publisher")
            let publishedDate = value(for: "Published Date")
            let isbn = value(for: "ISBN")
            let coverImageURL = value(for: "Cover Image URL")
            let bookDescription = value(for: "Description")
            let dateAdded = value(for: "Date Added").flatMap { dateFormatter.date(from: $0) } ?? .now
            let dateStarted = value(for: "Date Started").flatMap { dateFormatter.date(from: $0) }
            let dateFinished = value(for: "Date Finished").flatMap { dateFormatter.date(from: $0) }

            let book = Book(
                title: title,
                isbn: isbn,
                coverImageURL: coverImageURL,
                publisher: publisher,
                publishedDate: publishedDate,
                bookDescription: bookDescription,
                pageCount: pageCount,
                status: status,
                rating: rating,
                dateAdded: dateAdded,
                dateStarted: dateStarted,
                dateFinished: dateFinished
            )
            modelContext.insert(book)

            // Authors
            if let authorsString = value(for: "Authors") {
                let authorNames = authorsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                for name in authorNames where !name.isEmpty {
                    let key = name.lowercased()
                    if let existing = authorCache[key] {
                        book.authors.append(existing)
                    } else {
                        let author = Author(name: name)
                        modelContext.insert(author)
                        authorCache[key] = author
                        book.authors.append(author)
                    }
                }
            }

            // Tags
            if let tagsString = value(for: "Tags") {
                let tagNames = tagsString.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                for displayName in tagNames where !displayName.isEmpty {
                    if let tag = TagDeduplicator.findOrCreate(named: displayName, in: modelContext) {
                        book.tags.append(tag)
                    }
                }
            }

            // Notes
            if let notesString = value(for: "Notes") {
                let noteTexts = notesString.components(separatedBy: "; ")
                for text in noteTexts where !text.isEmpty {
                    let note = Note(content: text, book: book)
                    modelContext.insert(note)
                }
            }

            // Quotes
            if let quotesString = value(for: "Quotes") {
                let quoteEntries = quotesString.components(separatedBy: "; ")
                for entry in quoteEntries where !entry.isEmpty {
                    let (text, comment, page) = parseQuoteEntry(entry)
                    let quote = Quote(text: text, comment: comment, pageNumber: page, book: book)
                    modelContext.insert(quote)
                }
            }

            importedCount += 1
        }

        try modelContext.save()
        return importedCount
    }

    // MARK: - CSV Helpers

    private func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }

    private func parseCSVRows(_ content: String) -> [[String]] {
        var rows: [[String]] = []
        var currentField = ""
        var currentRow: [String] = []
        var inQuotes = false
        let chars = Array(content)
        var i = 0

        while i < chars.count {
            let c = chars[i]
            if inQuotes {
                if c == "\"" {
                    if i + 1 < chars.count, chars[i + 1] == "\"" {
                        currentField.append("\"")
                        i += 2
                    } else {
                        inQuotes = false
                        i += 1
                    }
                } else {
                    currentField.append(c)
                    i += 1
                }
            } else {
                if c == "\"" {
                    inQuotes = true
                    i += 1
                } else if c == "," {
                    currentRow.append(currentField)
                    currentField = ""
                    i += 1
                } else if c == "\n" || c == "\r" {
                    currentRow.append(currentField)
                    currentField = ""
                    if !currentRow.allSatisfy({ $0.isEmpty }) {
                        rows.append(currentRow)
                    }
                    currentRow = []
                    if c == "\r", i + 1 < chars.count, chars[i + 1] == "\n" {
                        i += 2
                    } else {
                        i += 1
                    }
                } else {
                    currentField.append(c)
                    i += 1
                }
            }
        }

        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            if !currentRow.allSatisfy({ $0.isEmpty }) {
                rows.append(currentRow)
            }
        }

        return rows
    }

    private func parseQuoteEntry(_ entry: String) -> (text: String, comment: String?, page: Int?) {
        var text = entry
        var comment: String?
        var page: Int?

        // Extract page number: (p. N) at end
        if let pageRange = text.range(of: #"\(p\.\s*(\d+)\)\s*$"#, options: .regularExpression) {
            let pageMatch = text[pageRange]
            if let numRange = pageMatch.range(of: #"\d+"#, options: .regularExpression) {
                page = Int(pageMatch[numRange])
            }
            text = String(text[text.startIndex..<pageRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        }

        // Extract comment: [Comment: ...] at end of remaining text
        if let commentRange = text.range(of: #"\[Comment:\s*(.*?)\]\s*$"#, options: .regularExpression) {
            let commentMatch = text[commentRange]
            if let contentRange = commentMatch.range(of: #"(?<=Comment:\s).*(?=\])"#, options: .regularExpression) {
                comment = String(commentMatch[contentRange]).trimmingCharacters(in: .whitespaces)
            }
            text = String(text[text.startIndex..<commentRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        }

        return (text, comment, page)
    }

    private func fetchRecentEntries() {
        var notesDescriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        notesDescriptor.fetchLimit = 10

        var quotesDescriptor = FetchDescriptor<Quote>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        quotesDescriptor.fetchLimit = 10

        let notes = (try? modelContext.fetch(notesDescriptor)) ?? []
        let quotes = (try? modelContext.fetch(quotesDescriptor)) ?? []

        let combined: [RecentEntry] =
            notes.map { .note($0) } + quotes.map { .quote($0) }

        recentEntries = combined.sorted { $0.date > $1.date }
    }
}
