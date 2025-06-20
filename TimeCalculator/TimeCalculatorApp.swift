//
//  TimeCalculatorApp.swift
//  TimeCalculator
//
//  Created by Gabe on 1/2/25.
//

import SwiftUI
import SwiftData

@main
struct TimeCalculatorApp: App {
    @StateObject private var themeManager = ThemeManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TimeEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
