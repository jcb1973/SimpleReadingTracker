//
//  SimpleReadingTrackerApp.swift
//  SimpleReadingTracker
//
//  Created by John Cieslik-Bridgen on 2026-02-12.
//

import SwiftUI
import CoreData

@main
struct SimpleReadingTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
