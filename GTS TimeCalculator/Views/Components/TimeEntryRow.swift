import SwiftUI
import SwiftData
import Foundation

struct TimeEntryRow: View {
    let entry: TimeEntryRowEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Index indicator with a colorful circle background
            ZStack {
                Circle()
                    .fill(colorForEntry(entry))
                    .frame(width: 36, height: 36)
                
                Text(entry.displayString)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if !entry.label.isEmpty {
                        Text(entry.label)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    // Format the date
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Make the entire row tappable
    }
    
    private func colorForEntry(_ entry: TimeEntryRowEntry) -> Color {
        switch entry.color {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        default: return .blue
        }
    }
}

struct TimeEntryRowEntry: Identifiable, Equatable {
    let id = UUID()
    var hours: Int
    var minutes: Int
    var seconds: Int
    var label: String = ""
    var color: String = "blue"
    var date: Date = Date()
    
    var displayString: String {
        String(format: "%02d:%02d", hours, minutes)
    }
} 