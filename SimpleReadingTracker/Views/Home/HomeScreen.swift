import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    var refreshTrigger: Int = 0

    var body: some View {
        Group {
            if let viewModel {
                homeContent(viewModel)
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
        .navigationTitle("Reading Tracker")
        .task {
            if viewModel == nil {
                let vm = HomeViewModel(modelContext: modelContext)
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

    @ViewBuilder
    private func homeContent(_ vm: HomeViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !vm.currentlyReading.isEmpty {
                    CurrentlyReadingSection(books: vm.currentlyReading)
                }

                if !vm.recentlyRead.isEmpty {
                    RecentlyReadSection(books: vm.recentlyRead)
                }

                if vm.currentlyReading.isEmpty && vm.recentlyRead.isEmpty {
                    EmptyStateView(
                        systemImage: "book.closed",
                        title: "No Books Yet",
                        message: "Add your first book to start tracking your reading."
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding()
        }
        .navigationDestination(for: Book.self) { book in
            BookDetailScreen(book: book)
        }
        .refreshable {
            vm.fetchBooks()
        }
    }
}
