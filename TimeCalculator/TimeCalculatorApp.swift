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
    let container: ModelContainer
    
    init() {
        do {
            // Configure SwiftData with iCloud sync
            let schema = Schema([TimeEntry.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .automatic
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
            ContentView()
            }
        }
        .modelContainer(container)
    }
}
