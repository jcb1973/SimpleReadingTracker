import Foundation
import Observation
import SwiftData

@Observable
final class HomeViewModel {
    private let modelContext: ModelContext

    private(set) var currentlyReading: [Book] = []
    private(set) var statusCounts: [ReadingStatus: Int] = [:]
    private(set) var ratingCounts: [Int: Int] = [:]
    private(set) var error: String?

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

            error = nil
        } catch {
            self.error = PersistenceError.fetchFailed(underlying: error).localizedDescription
        }
    }
}
