import SwiftUI
import SwiftData

struct LibraryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LibraryViewModel?
    var refreshTrigger: Int = 0

    var body: some View {
        Group {
            if let viewModel {
                libraryContent(viewModel)
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
        .navigationTitle("Library")
        .task {
            if viewModel == nil {
                let vm = LibraryViewModel(modelContext: modelContext)
                viewModel = vm
                vm.fetchBooks()
            }
        }
        .onAppear {
            viewModel?.fetchBooks()
        }
        .onChange(of: refreshTrigger) { _, _ in
            viewModel?.fetchBooks()
        }
    }

    private func libraryContent(_ vm: LibraryViewModel) -> some View {
        VStack(spacing: 0) {
            if !vm.allTags.isEmpty {
                LibraryTagBar(
                    tags: vm.allTags,
                    selectedTag: vm.tagFilter,
                    onSelect: {
                        vm.tagFilter = $0
                        vm.fetchBooks()
                    }
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            bookList(vm)
        }
    }

    private func bookList(_ vm: LibraryViewModel) -> some View {
        List {
            if vm.books.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "No Books Found",
                    message: vm.hasActiveFilters
                        ? "No books match your current filters. Try adjusting or clearing them."
                        : "Your library is empty. Add a book to get started."
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
                    .onAppear {
                        if book.persistentModelID == vm.books.last?.persistentModelID {
                            vm.loadMore()
                        }
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
                vm.searchTextDidChange()
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
                    ),
                    ratingFilter: Binding(
                        get: { vm.ratingFilter },
                        set: {
                            vm.ratingFilter = $0
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
