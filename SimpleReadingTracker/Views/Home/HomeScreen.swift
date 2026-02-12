import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HomeViewModel?

    var body: some View {
        Group {
            if let viewModel {
                homeContent(viewModel)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Reading Tracker")
        .task {
            let vm = HomeViewModel(modelContext: modelContext)
            viewModel = vm
            vm.fetchBooks()
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
        .refreshable {
            vm.fetchBooks()
        }
    }
}
