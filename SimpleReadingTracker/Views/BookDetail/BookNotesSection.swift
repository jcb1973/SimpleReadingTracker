import SwiftUI

struct BookNotesSection: View {
    @Bindable var viewModel: BookDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("Notes")
                    .font(.headline)
                if viewModel.notesSaved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.notesSaved)

            TextEditor(text: $viewModel.noteText)
                .frame(minHeight: 150)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onDisappear {
                    viewModel.saveNotesNow()
                }
        }
    }
}
