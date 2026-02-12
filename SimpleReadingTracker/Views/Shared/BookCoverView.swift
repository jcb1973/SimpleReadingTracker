import SwiftUI

struct BookCoverView: View {
    let coverImageData: Data?
    let coverImageURL: String?
    let size: CGSize

    var body: some View {
        Group {
            if let data = coverImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let urlString = coverImageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        placeholder
                    default:
                        ProgressView()
                            .frame(width: size.width, height: size.height)
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary)
            .frame(width: size.width, height: size.height)
            .overlay {
                Image(systemName: "book.closed")
                    .font(size.height > 120 ? .title : .title2)
                    .foregroundStyle(.secondary)
            }
    }
}
