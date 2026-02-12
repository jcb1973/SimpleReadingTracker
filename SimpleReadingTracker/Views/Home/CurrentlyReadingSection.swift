import SwiftUI

struct CurrentlyReadingSection: View {
    let books: [Book]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Currently Reading", systemImage: "book.fill")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(books) { book in
                        NavigationLink(value: book) {
                            BookCard(book: book)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationDestination(for: Book.self) { book in
            BookDetailScreen(book: book)
        }
    }
}
