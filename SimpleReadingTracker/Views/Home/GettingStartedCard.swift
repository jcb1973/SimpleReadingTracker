import SwiftUI

struct GettingStartedCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("Getting Started", systemImage: "sparkles")
                .font(.title3.weight(.semibold))

            tipRow(
                icon: "barcode.viewfinder",
                title: "Scan a barcode",
                detail: "Tap the + button below, then use \"Scan Barcode\" to point your camera at a book's ISBN. The title, author, and cover fill in automatically."
            )

            tipRow(
                icon: "keyboard",
                title: "Type an ISBN",
                detail: "No barcode handy? Enter the ISBN number manually and tap \"Lookup\" to fetch the book details."
            )

            tipRow(
                icon: "square.and.pencil",
                title: "Add manually",
                detail: "You can also type in the title, author, and other details yourself — no ISBN needed."
            )

            tipRow(
                icon: "quote.opening",
                title: "Save quotes & notes",
                detail: "Once a book is added, open it to save your favourite passages and reading notes."
            )
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func tipRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
