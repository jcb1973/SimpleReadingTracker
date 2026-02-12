import SwiftUI

struct BookActionsSection: View {
    @Bindable var viewModel: BookDetailViewModel
    @Binding var showingEditSheet: Bool
    @Binding var showingDeleteConfirmation: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions")
                .font(.headline)

            ratingSection
            buttonSection
        }
    }

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rating")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            StarRatingView(rating: Binding(
                get: { viewModel.book.rating },
                set: { viewModel.updateRating($0) }
            ))
        }
    }

    private var buttonSection: some View {
        HStack {
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}
