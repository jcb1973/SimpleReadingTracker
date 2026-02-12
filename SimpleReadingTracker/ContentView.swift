import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingAddBook = false
    @State private var homePath = NavigationPath()
    @State private var libraryPath = NavigationPath()
    @State private var refreshTrigger = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeScreen(refreshTrigger: refreshTrigger)
                    .addBookOverlay(showingAddBook: $showingAddBook)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack(path: $libraryPath) {
                LibraryScreen(refreshTrigger: refreshTrigger)
                    .addBookOverlay(showingAddBook: $showingAddBook)
            }
            .tabItem {
                Label("Library", systemImage: "books.vertical.fill")
            }
            .tag(1)
        }
        .onChange(of: selectedTab) { _, _ in
            homePath = NavigationPath()
            libraryPath = NavigationPath()
        }
        .sheet(isPresented: $showingAddBook, onDismiss: { refreshTrigger += 1 }) {
            NavigationStack {
                BookFormScreen(mode: .add)
            }
        }
    }
}

private struct AddBookOverlay: ViewModifier {
    @Binding var showingAddBook: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                Button {
                    showingAddBook = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.accentColor)
                        .shadow(radius: 4)
                }
                .padding(.bottom, 8)
            }
    }
}

private extension View {
    func addBookOverlay(showingAddBook: Binding<Bool>) -> some View {
        modifier(AddBookOverlay(showingAddBook: showingAddBook))
    }
}
