import SwiftUI

struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BookCoverView(
                coverImageData: book.coverImageData,
                coverImageURL: book.coverImageURL,
                size: CGSize(width: 140, height: 160)
            )
            bookInfo
        }
        .frame(width: 140)
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var bookInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(book.title)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
            Text(book.authorNames)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
