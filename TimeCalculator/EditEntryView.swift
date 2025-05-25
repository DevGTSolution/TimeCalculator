import SwiftUI
import SwiftData

struct EditEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // State
    @State private var hours: Double = 0
    @State private var minutes: Double = 0
    @State private var label: String = ""
    @State private var date: Date = Date()
    @State private var selectedColor: String = "blue"
    
    private let entry: TimeEntry?
    private let isNewEntry: Bool
    
    private let colorOptions = ["blue", "green", "orange", "purple", "red"]
    
    // Initialize for new entry
    init(isNewEntry: Bool = true) {
        self.isNewEntry = isNewEntry
        self.entry = nil
    }
    
    // Initialize for editing existing entry
    init(entry: TimeEntry) {
        self.isNewEntry = false
        self.entry = entry
        
        // Initialize with entry values
        _hours = State(initialValue: Double(entry.hours))
        _minutes = State(initialValue: Double(entry.minutes))
        _label = State(initialValue: entry.label)
        _date = State(initialValue: entry.date)
        _selectedColor = State(initialValue: entry.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time Duration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hours")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("", value: $hours, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.medium)
                            
                            Stepper("", value: $hours, in: 0...24, step: 1)
                                .labelsHidden()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("", value: $minutes, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.medium)
                            
                            Stepper("", value: $minutes, in: 0...59, step: 5)
                                .labelsHidden()
                        }
                    }
                }
                
                Section(header: Text("Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Label (Optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g. Work, Project, Study", text: $label)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
                
                Section(header: Text("Color")) {
                    HStack(spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            ZStack {
                                Circle()
                                    .fill(colorForOption(color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                                
                                if selectedColor == color {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                if !isNewEntry {
                    Section {
                        Button(role: .destructive) {
                            if let entry = entry {
                                modelContext.delete(entry)
                                dismiss()
                            }
                        } label: {
                            Text("Delete Entry")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle(isNewEntry ? "Add Time Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
    
    private func saveEntry() {
        if let existingEntry = entry {
            // Update existing entry
            existingEntry.hours = Int(hours)
            existingEntry.minutes = Int(minutes)
            existingEntry.date = date
            existingEntry.label = label
            existingEntry.color = selectedColor
            existingEntry.lastModified = Date()
            existingEntry.isSynced = false
        } else {
            // Create new entry
            let newEntry = TimeEntry(
                hours: Int(hours),
                minutes: Int(minutes),
                date: date,
                label: label,
                color: selectedColor
            )
            modelContext.insert(newEntry)
        }
    }
    
    private func colorForOption(_ colorName: String) -> Color {
        switch colorName {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        default: return .blue
        }
    }
}
