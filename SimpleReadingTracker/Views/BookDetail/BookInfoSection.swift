import PhotosUI
import SwiftUI

struct BookInfoSection: View {
    let book: Book
    var onCoverImageSelected: ((Data) -> Void)?
    var onStatusTapped: (() -> Void)?
    var onRatingChanged: ((Int?) -> Void)?

    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerRow
            if let description = book.bookDescription, !description.isEmpty {
                descriptionSection(description)
            }
        }
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 16) {
            coverWithPicker
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(book.authorNames)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button {
                    onStatusTapped?()
                } label: {
                    StatusBadge(status: book.status)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Status: \(book.status.displayName)")
                .accessibilityHint("Cycle reading status")
                StarRatingView(rating: Binding(
                    get: { book.rating },
                    set: { onRatingChanged?($0) }
                ))
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    onCoverImageSelected?(data)
                }
                selectedPhoto = nil
            }
        }
    }

    private var coverWithPicker: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            BookCoverView(
                coverImageData: book.coverImageData,
                coverImageURL: book.coverImageURL,
                size: CGSize(width: 100, height: 150)
            )
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "camera.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .blue)
                    .offset(x: 4, y: 4)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Book cover")
        .accessibilityHint("Change cover image")
    }

    private func descriptionSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Description")
                .font(.headline)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}
