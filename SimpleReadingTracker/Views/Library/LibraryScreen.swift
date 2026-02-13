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
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Library")
        // FIX: Moved here so the search bar is registered on first load
        .searchable(text: Binding(
            get: { viewModel?.searchText ?? "" },
            set: {
                viewModel?.searchText = $0
                viewModel?.searchTextDidChange()
            }
        ), prompt: "Search books, authors, notes...")
        .toolbar {
            navigationToolbarItems
        }
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
        .navigationDestination(for: Book.self) { book in
            BookDetailScreen(book: book)
        }
    }

    // MARK: - Subviews

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
        // MODIFIERS REMOVED FROM HERE TO PREVENT DISAPPEARING ON LOAD
    }

    @ToolbarContentBuilder
    private var navigationToolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if let vm = viewModel {
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
        }
        ToolbarItem(placement: .topBarTrailing) {
            if let vm = viewModel {
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
