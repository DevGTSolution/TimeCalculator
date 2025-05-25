import Foundation
import SwiftData

public enum TimeCalculatorModels {}

@Model
final class TimeEntry {
    var id: UUID
    var days: Int
    var hours: Int
    var minutes: Int
    var seconds: Int
    var date: Date
    var label: String
    var color: String
    var lastModified: Date
    var isSynced: Bool
    
    init(
        id: UUID = UUID(),
        days: Int = 0,
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0,
        date: Date = Date(),
        label: String = "",
        color: String = "blue"
    ) {
        self.id = id
        self.days = days
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.date = date
        self.label = label
        self.color = color
        self.lastModified = Date()
        self.isSynced = false
    }
    
    var totalSeconds: Int {
        (days * 24 * 3600) + (hours * 3600) + (minutes * 60) + seconds
    }
    
    var totalHours: Double {
        Double(totalSeconds) / 3600
    }
    
    var displayString: String {
        "\(Int(hours))h \(Int(minutes))m"
    }
} 