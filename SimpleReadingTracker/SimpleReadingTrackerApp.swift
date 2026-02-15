import SwiftUI
import SwiftData

@main
struct SimpleReadingTrackerApp: App {
    @State private var modelContainer: ModelContainer?

    private var isSeedingEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--seed-sample-data")
    }

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                ContentView()
                    .modelContainer(modelContainer)
            } else {
                ProgressView()
                    .task {
                        do {
                            let config: ModelConfiguration
                            if isSeedingEnabled {
                                config = ModelConfiguration(isStoredInMemoryOnly: true)
                            } else {
                                config = ModelConfiguration()
                            }
                            let container = try ModelContainer(
                                for: Book.self,
                                configurations: config
                            )
                            if isSeedingEnabled {
                                SampleDataSeeder.seed(into: container.mainContext)
                            }
                            modelContainer = container
                        } catch {
                            modelContainer = try? ModelContainer(for: Book.self)
                        }
                    }
            }
        }
    }
}
