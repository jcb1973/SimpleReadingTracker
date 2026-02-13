import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?
    var refreshTrigger: Int = 0
    var onStatusTapped: ((ReadingStatus) -> Void)?
    var onRatingTapped: ((Int) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let vm = viewModel {
                    if !vm.currentlyReading.isEmpty {
                        CurrentlyReadingSection(books: vm.currentlyReading)
                    }

                    ReadingStatsCard(statusCounts: vm.statusCounts) { status in
                        onStatusTapped?(status)
                    }

                    StarNavigator(ratingCounts: vm.ratingCounts) { rating in
                        onRatingTapped?(rating)
                    }

                    if vm.currentlyReading.isEmpty {
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
        .navigationTitle("Reading Notebook")
        .navigationDestination(for: Book.self) { book in
            BookDetailScreen(book: book)
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
            viewModel?.fetchBooks()
        }
        .onChange(of: refreshTrigger) { _, _ in
            viewModel?.fetchBooks()
        }
    }
}
