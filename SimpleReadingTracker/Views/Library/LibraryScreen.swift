import SwiftUI
import SwiftData

struct LibraryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LibraryViewModel?

    var body: some View {
        Group {
            if let viewModel {
                libraryContent(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Library")
        .task {
            if viewModel == nil {
                viewModel = LibraryViewModel(modelContext: modelContext)
            }
        }
        .onAppear {
            viewModel?.fetchBooks()
        }
    }

    private func libraryContent(_ vm: LibraryViewModel) -> some View {
        List {
            if vm.books.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "No Books Found",
                    message: vm.searchText.isEmpty
                        ? "Your library is empty. Add a book to get started."
                        : "No books match your search."
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(vm.books) { book in
                    NavigationLink(value: book) {
                        LibraryBookRow(
                            book: book,
                            matchReasons: vm.matchReasons(for: book)
                        )
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            vm.deleteBook(book)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        statusSwipeActions(for: book, vm: vm)
                    }
                }
            }
        }
        .searchable(text: Binding(
            get: { vm.searchText },
            set: {
                vm.searchText = $0
                vm.fetchBooks()
            }
        ), prompt: "Search books, authors, tags...")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LibrarySortMenu(
                    sortOption: Binding(
                        get: { vm.sortOption },
                        set: {
                            vm.sortOption = $0
                            vm.fetchBooks()
                        }
                    ),
                    ascending: Binding(
                        get: { vm.sortAscending },
                        set: {
                            vm.sortAscending = $0
                            vm.fetchBooks()
                        }
                    )
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                LibraryFilterView(
                    statusFilter: Binding(
                        get: { vm.statusFilter },
                        set: {
                            vm.statusFilter = $0
                            vm.fetchBooks()
                        }
                    )
                )
            }
        }
        .navigationDestination(for: Book.self) { book in
            BookDetailScreen(book: book)
        }
    }

    @ViewBuilder
    private func statusSwipeActions(for book: Book, vm: LibraryViewModel) -> some View {
        switch book.status {
        case .toRead:
            Button {
                vm.updateStatus(for: book, to: .reading)
            } label: {
                Label("Start Reading", systemImage: "book.fill")
            }
            .tint(.orange)
        case .reading:
            Button {
                vm.updateStatus(for: book, to: .read)
            } label: {
                Label("Mark Read", systemImage: "checkmark.circle.fill")
            }
            .tint(.green)
        case .read:
            Button {
                vm.updateStatus(for: book, to: .toRead)
            } label: {
                Label("Read Again", systemImage: "arrow.counterclockwise")
            }
            .tint(.blue)
        }
    }
}
