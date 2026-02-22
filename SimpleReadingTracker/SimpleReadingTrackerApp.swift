import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
}
#endif

@main
struct SimpleReadingTrackerApp: App {
    #if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
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
