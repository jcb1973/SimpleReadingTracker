import SwiftUI
import SwiftData

@main
struct SimpleReadingTrackerApp: App {
    @State private var modelContainer: ModelContainer?

    #if DEBUG
    private var isSeedingEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("--seed-sample-data")
    }
    #endif

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
                            #if DEBUG
                            if isSeedingEnabled {
                                config = ModelConfiguration(isStoredInMemoryOnly: true)
                            } else {
                                config = ModelConfiguration(cloudKitDatabase: .automatic)
                            }
                            #else
                            config = ModelConfiguration(cloudKitDatabase: .automatic)
                            #endif
                            let container = try ModelContainer(
                                for: Book.self,
                                configurations: config
                            )
                            #if DEBUG
                            if isSeedingEnabled {
                                SampleDataSeeder.seed(into: container.mainContext)
                            }
                            #endif
                            TagDeduplicator.deduplicateAll(in: container.mainContext)
                            modelContainer = container
                        } catch {
                            let fallbackConfig = ModelConfiguration(cloudKitDatabase: .automatic)
                            modelContainer = try? ModelContainer(
                                for: Book.self,
                                configurations: fallbackConfig
                            )
                        }
                    }
            }
        }
    }
}
