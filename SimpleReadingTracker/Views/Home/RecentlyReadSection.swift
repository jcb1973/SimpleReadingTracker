import SwiftUI

struct RecentlyReadSection: View {
    let books: [Book]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recently Read", systemImage: "checkmark.circle.fill")
                .font(.headline)

            ForEach(books) { book in
                NavigationLink(value: book) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(book.authorNames)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let rating = book.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text("\(rating)")
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
