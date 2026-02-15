import SwiftUI
import SwiftData

private struct BookDeletion {
    let id: PersistentIdentifier
    let title: String
}

struct LibraryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LibraryViewModel?
    @State private var showingManageTags = false
    @State private var bookToDelete: BookDeletion?
    @State private var hasAppeared = false
    var refreshTrigger: Int = 0
    var statusFilterOverride: Binding<ReadingStatus?> = .constant(nil)
    var ratingFilterOverride: Binding<Int?> = .constant(nil)
    var clearFilters: Binding<Bool> = .constant(false)

    var body: some View {
        List {
            Section {
                LogoTitle(title: "Library")

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    TextField("Search books, authors, notes...", text: Binding(
                        get: { viewModel?.searchText ?? "" },
                        set: {
                            viewModel?.searchText = $0
                            viewModel?.searchTextDidChange()
                        }
                    ))
                }
                .padding(8)
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

            if let vm = viewModel {
                if !vm.allTags.isEmpty {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            LibraryTagBar(
                                tags: vm.allTags,
                                selectedTagIDs: Set(vm.tagFilters.map(\.persistentModelID)),
                                tagFilterMode: vm.tagFilterMode,
                                onToggle: { vm.toggleTag($0) },
                                onToggleMode: {
                                    vm.tagFilterMode = vm.tagFilterMode == .and ? .or : .and
                                    vm.fetchBooks()
                                }
                            )

                            Button {
                                showingManageTags = true
                            } label: {
                                Label("Manage Tags", systemImage: "tag")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }

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
                                matchReasons: vm.matchReasons(for: book),
                                onStatusTapped: {
                                    cycleStatus(for: book, vm: vm)
                                }
                            )
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.regularMaterial)
                                .padding(.vertical, 6)
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .onAppear {
                            if book.persistentModelID == vm.books.last?.persistentModelID {
                                vm.loadMore()
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                bookToDelete = BookDeletion(
                                    id: book.persistentModelID,
                                    title: book.title
                                )
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
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
        .listStyle(.plain)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let vm = viewModel {
                sortFilterToolbarItems(vm: vm)
            }
        }
        .task {
            if viewModel == nil {
                let vm = LibraryViewModel(modelContext: modelContext)
                viewModel = vm
                applyOverrides(vm)
                vm.fetchBooks()
            }
        }
        .onAppear {
            guard hasAppeared else {
                hasAppeared = true
                return
            }
            guard let vm = viewModel else { return }
            applyOverrides(vm)
            vm.fetchBooks()
        }
        .onChange(of: refreshTrigger) { _, _ in
            viewModel?.fetchBooks()
        }
        .onChange(of: statusFilterOverride.wrappedValue) { _, newValue in
            guard let status = newValue, let vm = viewModel else { return }
            vm.ratingFilter = nil
            vm.tagFilters = []
            vm.searchText = ""
            vm.statusFilter = status
            vm.fetchBooks()
            statusFilterOverride.wrappedValue = nil
        }
        .onChange(of: ratingFilterOverride.wrappedValue) { _, newValue in
            guard let rating = newValue, let vm = viewModel else { return }
            vm.statusFilter = nil
            vm.tagFilters = []
            vm.searchText = ""
            vm.ratingFilter = rating
            vm.fetchBooks()
            ratingFilterOverride.wrappedValue = nil
        }
        .onChange(of: clearFilters.wrappedValue) { _, shouldClear in
            guard shouldClear, let vm = viewModel else { return }
            vm.statusFilter = nil
            vm.ratingFilter = nil
            vm.tagFilters = []
            vm.searchText = ""
            vm.fetchBooks()
            clearFilters.wrappedValue = false
        }
        .sheet(isPresented: $showingManageTags, onDismiss: {
            viewModel?.fetchBooks()
        }) {
            ManageTagsScreen()
        }
        .alert("Delete Book", isPresented: Binding(
            get: { bookToDelete != nil },
            set: { if !$0 { bookToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let deletion = bookToDelete {
                    withAnimation {
                        viewModel?.deleteBook(id: deletion.id)
                    }
                    bookToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                bookToDelete = nil
            }
        } message: {
            if let deletion = bookToDelete {
                Text("Are you sure you want to delete \"\(deletion.title)\"? This cannot be undone.")
            }
        }
        .navigationDestination(for: Book.self) { book in
            BookDetailScreen(book: book)
        }
    }

    // MARK: - Helpers

    private func applyOverrides(_ vm: LibraryViewModel) {
        let hasOverride = statusFilterOverride.wrappedValue != nil
            || ratingFilterOverride.wrappedValue != nil
        guard hasOverride else { return }

        vm.statusFilter = nil
        vm.ratingFilter = nil
        vm.tagFilters = []
        vm.searchText = ""

        if let status = statusFilterOverride.wrappedValue {
            vm.statusFilter = status
            statusFilterOverride.wrappedValue = nil
        }
        if let rating = ratingFilterOverride.wrappedValue {
            vm.ratingFilter = rating
            ratingFilterOverride.wrappedValue = nil
        }
    }

    // MARK: - Sort / Filter

    @ToolbarContentBuilder
    private func sortFilterToolbarItems(vm: LibraryViewModel) -> some ToolbarContent {
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

    // MARK: - Status Cycling

    private func cycleStatus(for book: Book, vm: LibraryViewModel) {
        let newStatus = book.status.next
        vm.updateStatus(for: book, to: newStatus)

        if vm.hasStatusFilter {
            Task {
                try? await Task.sleep(for: .milliseconds(600))
                withAnimation(.easeInOut(duration: 0.35)) {
                    vm.fetchBooks()
                }
            }
        } else {
            vm.fetchBooks()
        }
    }

}
