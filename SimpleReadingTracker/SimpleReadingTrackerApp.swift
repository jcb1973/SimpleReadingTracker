import SwiftUI
import SwiftData

@main
struct SimpleReadingTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Book.self)
    }
}
