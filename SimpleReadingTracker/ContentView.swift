import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingAddBook = false
    @State private var homePath = NavigationPath()
    @State private var libraryPath = NavigationPath()
    @State private var refreshTrigger = 0
    @State private var libraryStatusFilter: ReadingStatus?
    @State private var libraryRatingFilter: Int?
    @State private var libraryClearFilters = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                NavigationStack(path: $homePath) {
                    HomeScreen(
                        refreshTrigger: refreshTrigger,
                        onStatusTapped: { status in
                            libraryStatusFilter = status
                            selectedTab = 1
                        },
                        onRatingTapped: { rating in
                            libraryRatingFilter = rating
                            selectedTab = 1
                        }
                    )
                }
                .opacity(selectedTab == 0 ? 1 : 0)
                .allowsHitTesting(selectedTab == 0)

                NavigationStack(path: $libraryPath) {
                    LibraryScreen(
                        refreshTrigger: refreshTrigger,
                        statusFilterOverride: $libraryStatusFilter,
                        ratingFilterOverride: $libraryRatingFilter,
                        clearFilters: $libraryClearFilters
                    )
                }
                .opacity(selectedTab == 1 ? 1 : 0)
                .allowsHitTesting(selectedTab == 1)
            }

            Divider()

            customTabBar
        }
        .onChange(of: selectedTab) { _, newTab in
            homePath = NavigationPath()
            libraryPath = NavigationPath()
            refreshTrigger += 1
            if newTab == 1,
               libraryStatusFilter == nil,
               libraryRatingFilter == nil {
                libraryClearFilters = true
            }
        }
        .sheet(isPresented: $showingAddBook, onDismiss: { refreshTrigger += 1 }) {
            NavigationStack {
                BookFormScreen(mode: .add)
            }
        }
    }

    private var customTabBar: some View {
        HStack {
            tabButton(label: "Home", systemImage: "house.fill", tag: 0)

            Spacer()

            Button {
                showingAddBook = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }

            Spacer()

            tabButton(label: "Library", systemImage: "books.vertical.fill", tag: 1)
        }
        .padding(.horizontal, 40)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color(.systemBackground))
    }

    private func tabButton(label: String, systemImage: String, tag: Int) -> some View {
        Button {
            if selectedTab == tag {
                if tag == 0 { homePath = NavigationPath() }
                if tag == 1 { libraryPath = NavigationPath() }
            } else {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(selectedTab == tag ? Color.accentColor : .secondary)
            .frame(minWidth: 60)
        }
        .buttonStyle(.plain)
    }
}
