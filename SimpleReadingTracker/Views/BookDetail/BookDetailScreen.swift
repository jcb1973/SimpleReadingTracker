import SwiftUI
import SwiftData

struct BookDetailScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: BookDetailViewModel?
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingManageTags = false

    let book: Book

    var body: some View {
        Group {
            if let viewModel {
                detailContent(viewModel)
            } else {
                ProgressView()
            }
        }
        .background {
            LinearGradient(
                colors: [Color(.systemBackground), Color.blue.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Book details")
        .task {
            viewModel = BookDetailViewModel(book: book, modelContext: modelContext)
        }
    }

    private func detailContent(_ vm: BookDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                BookInfoSection(
                    book: vm.book,
                    onCoverImageSelected: { imageData in
                        if let compressed = BookFormViewModel.compressImage(
                            imageData, maxWidth: 600, quality: 0.7
                        ) {
                            vm.updateCoverImage(compressed)
                        }
                    },
                    onStatusTapped: {
                        vm.cycleStatus()
                    },
                    onRatingChanged: { rating in
                        vm.updateRating(rating)
                    }
                )
                BookTagsSection(
                    book: vm.book,
                    onAdd: { vm.addTag(named: $0) },
                    onRemove: { vm.removeTag($0) }
                )
                Button {
                    showingManageTags = true
                } label: {
                    Label("Manage Tags", systemImage: "tag")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                NotesQuotesSection(book: vm.book)
                BookActionsSection(
                    viewModel: vm,
                    showingEditSheet: $showingEditSheet,
                    showingDeleteConfirmation: $showingDeleteConfirmation
                )
            }
            .padding()
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                BookFormScreen(mode: .edit(vm.book))
            }
        }
        .sheet(isPresented: $showingManageTags) {
            ManageTagsScreen()
        }
        .alert("Delete Book", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                vm.deleteBook()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(vm.book.title)\"? This cannot be undone.")
        }
    }
}
