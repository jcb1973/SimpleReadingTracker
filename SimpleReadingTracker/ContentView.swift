import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingAddBook = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeScreen()
            }
            .addBookOverlay(showingAddBook: $showingAddBook)
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                LibraryScreen()
            }
            .addBookOverlay(showingAddBook: $showingAddBook)
            .tabItem {
                Label("Library", systemImage: "books.vertical.fill")
            }
            .tag(1)
        }
        .sheet(isPresented: $showingAddBook) {
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
