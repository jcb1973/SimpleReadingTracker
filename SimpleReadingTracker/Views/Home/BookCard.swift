import SwiftUI

struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BookCoverView(
                coverImageData: book.coverImageData,
                coverImageURL: book.coverImageURL,
                size: CGSize(width: 160, height: 200),
                cornerRadius: 16
            )
            bookInfo
        }
        .frame(width: 160)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
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
