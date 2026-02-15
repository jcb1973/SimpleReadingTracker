import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct HomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    @State private var showingExportSheet = false
    @State private var exportFileURL: URL?
    @State private var showingImportPicker = false
    @State private var showingImportResult = false
    @State private var hasAppeared = false
    var refreshTrigger: Int = 0
    var onStatusTapped: ((ReadingStatus) -> Void)?
    var onRatingTapped: ((Int) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LogoTitle(title: "Home")

                if let vm = viewModel {
                    if !vm.currentlyReading.isEmpty {
                        CurrentlyReadingSection(books: vm.currentlyReading)
                    }

                    ReadingStatsCard(statusCounts: vm.statusCounts) { status in
                        onStatusTapped?(status)
                    }

                    RecentNotesQuotesSection(entries: vm.recentEntries)

                    if vm.statusCounts.values.reduce(0, +) == 0 {
                        EmptyStateView(
                            systemImage: "book.closed",
                            title: "No Books Yet",
                            message: "Add your first book to start tracking your reading."
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                }
            }
            .padding()
        }
        .background {
            LinearGradient(
                colors: [Color(.systemBackground), Color.blue.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        if let url = viewModel?.exportCSV() {
                            exportFileURL = url
                            showingExportSheet = true
                        }
                    } label: {
                        Label("Export (CSV)", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showingImportPicker = true
                    } label: {
                        Label("Import (CSV)", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .accessibilityLabel("More options")
                }
            }
        }
        .navigationDestination(for: Book.self) { book in
            BookDetailScreen(book: book)
        }
        .navigationDestination(for: BookDetailDestination.self) { destination in
            BookDetailScreen(book: destination.book, initialTab: destination.initialTab)
        }
        .refreshable {
            viewModel?.fetchBooks()
        }
        .task {
            if viewModel == nil {
                let vm = HomeViewModel(modelContext: modelContext)
                viewModel = vm
                vm.fetchBooks()
            }
        }
        .onAppear {
            guard hasAppeared else {
                hasAppeared = true
                return
            }
            viewModel?.fetchBooks()
        }
        .onChange(of: refreshTrigger) { _, _ in
            viewModel?.fetchBooks()
        }
        .shareSheet(
            isPresented: $showingExportSheet,
            activityItems: exportFileURL.map { [$0] } ?? []
        )
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [UTType.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first, let vm = viewModel else { return }
                do {
                    let count = try vm.importCSV(from: url)
                    vm.importResult = "Successfully imported \(count) book\(count == 1 ? "" : "s")."
                    vm.fetchBooks()
                } catch {
                    vm.importResult = "Import failed: \(error.localizedDescription)"
                }
                showingImportResult = true
            case .failure(let error):
                viewModel?.importResult = "Import failed: \(error.localizedDescription)"
                showingImportResult = true
            }
        }
        .alert("Import", isPresented: $showingImportResult) {
            Button("OK") {
                viewModel?.importResult = nil
            }
        } message: {
            if let result = viewModel?.importResult {
                Text(result)
            }
        }
    }
}
