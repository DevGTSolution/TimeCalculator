import SwiftUI
import SwiftData
import Foundation

struct TimeEntryRow: View {
    let entry: TimeEntryRowEntry
    var onEditLabel: ((TimeEntryRowEntry) -> Void)?
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            // Index indicator with a colorful circle background
            ZStack {
                Circle()
                    .fill(themeColorForEntry(entry))
                    .frame(width: 36, height: 36)
                
                Text(entry.displayString)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if !entry.label.isEmpty {
                        Text(entry.label)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    // Format the date and time
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(entry.date, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Make the entire row tappable
        .onLongPressGesture {
            onEditLabel?(entry)
        }
    }
    
    private func themeColorForEntry(_ entry: TimeEntryRowEntry) -> Color {
        // If the entry color matches the current theme, use the theme's accent color
        if entry.color.lowercased() == themeManager.currentTheme.name.lowercased() {
            return themeManager.currentTheme.accentColor
        }
        // Otherwise, use the entry's color as before
        switch entry.color {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        default: return themeManager.currentTheme.accentColor
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
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 