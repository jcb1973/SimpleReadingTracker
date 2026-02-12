import SwiftUI

struct BookNotesSection: View {
    @Bindable var viewModel: BookDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)

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
