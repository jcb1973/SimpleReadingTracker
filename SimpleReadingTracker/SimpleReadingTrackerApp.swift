import SwiftUI
import SwiftData

@main
struct SimpleReadingTrackerApp: App {
    @State private var modelContainer: ModelContainer?

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                ContentView()
                    .modelContainer(modelContainer)
            } else {
                ProgressView()
                    .task {
                        modelContainer = try? ModelContainer(for: Book.self)
                    }
            }
        }
    }
}
