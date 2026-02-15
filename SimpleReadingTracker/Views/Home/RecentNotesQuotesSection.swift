import SwiftUI
import SwiftData

struct BookDetailDestination: Hashable {
    let book: Book
    let initialTab: NotesQuotesTab

    func hash(into hasher: inout Hasher) {
        hasher.combine(book.persistentModelID)
        hasher.combine(initialTab)
    }

    static func == (lhs: BookDetailDestination, rhs: BookDetailDestination) -> Bool {
        lhs.book.persistentModelID == rhs.book.persistentModelID
            && lhs.initialTab == rhs.initialTab
    }
}

struct RecentNotesQuotesSection: View {
    let entries: [RecentEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Latest Notes & Quotes", systemImage: "text.quote")
                .font(.headline)

            if entries.isEmpty {
                Text("Add notes and quotes from your book details.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(entries) { entry in
                            if let book = entry.book {
                                NavigationLink(value: BookDetailDestination(
                                    book: book,
                                    initialTab: entry.tab
                                )) {
                                    RecentEntryCardView(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
}
