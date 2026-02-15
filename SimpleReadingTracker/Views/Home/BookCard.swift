import SwiftUI

struct BookCard: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            BookCoverView(
                coverImageData: book.coverImageData,
                coverImageURL: book.coverImageURL,
                size: CGSize(width: 140, height: 160),
                cornerRadius: 14
            )
            bookInfo
        }
        .frame(width: 140)
        .padding(10)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(book.title) by \(book.authorNames)")
    }

    private var bookInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(book.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            Text(book.authorNames)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
