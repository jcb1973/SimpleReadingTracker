import SwiftUI
import SwiftData

struct LibraryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: LibraryViewModel?
    @State private var showingManageTags = false
    @State private var showingExportSheet = false
    @State private var exportFileURL: URL?
    @State private var bookToDelete: Book?
    var refreshTrigger: Int = 0
    var statusFilterOverride: Binding<ReadingStatus?> = .constant(nil)
    var ratingFilterOverride: Binding<Int?> = .constant(nil)
    var clearFilters: Binding<Bool> = .constant(false)

    var body: some View {
        List {
            Section {
                HStack {
                    LogoTitle(title: "Library")
                    Spacer()
                    if let vm = viewModel {
                        sortFilterButtons(vm: vm)
                    }
                }

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
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
                                matchReasons: vm.matchReasons(for: book)
                            )
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.regularMaterial)
                                .padding(.vertical, 4)
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
                                bookToDelete = book
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
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if viewModel == nil {
                let vm = LibraryViewModel(modelContext: modelContext)
                viewModel = vm
                applyOverrides(vm)
                vm.fetchBooks()
            }
        }
        .onAppear {
            if let vm = viewModel {
                applyOverrides(vm)
            }
            viewModel?.fetchBooks()
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
        .shareSheet(
            isPresented: $showingExportSheet,
            activityItems: exportFileURL.map { [$0] } ?? []
        )
        .alert("Delete Book", isPresented: Binding(
            get: { bookToDelete != nil },
            set: { if !$0 { bookToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let book = bookToDelete {
                    viewModel?.deleteBook(book)
                    bookToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                bookToDelete = nil
            }
        } message: {
            if let book = bookToDelete {
                Text("Are you sure you want to delete \"\(book.title)\"? This cannot be undone.")
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

    @ViewBuilder
    private func sortFilterButtons(vm: LibraryViewModel) -> some View {
        HStack(spacing: 12) {
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
                ),
                onExport: {
                    if let url = vm.exportCSV() {
                        exportFileURL = url
                        showingExportSheet = true
                    }
                }
            )
        }
        .font(.title3)
        .foregroundStyle(.secondary)
    }

    // MARK: - Swipe Actions

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
