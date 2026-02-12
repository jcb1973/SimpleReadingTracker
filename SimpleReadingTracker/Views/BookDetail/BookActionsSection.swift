import SwiftUI

struct BookActionsSection: View {
    @Bindable var viewModel: BookDetailViewModel
    @Binding var showingEditSheet: Bool
    @Binding var showingDeleteConfirmation: Bool

    var body: some View {
        buttonSection
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
