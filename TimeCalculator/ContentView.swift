import SwiftUI

// MARK: - Model
struct TimeEntry: Identifiable {
    let id: UUID
    var days: Int
    var hours: Int
    var minutes: Int
    var seconds: Int
    
    init(id: UUID = UUID(), days: Int, hours: Int, minutes: Int, seconds: Int) {
        self.id = id
        self.days = days
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    var totalSeconds: Int {
        (days * 24 * 3600) + (hours * 3600) + (minutes * 60) + seconds
    }
}

// MARK: - Utility
func formattedTimeString(from totalSeconds: Int) -> String {
    let days = totalSeconds / (24 * 3600)
    let remainderDays = totalSeconds % (24 * 3600)
    let hours = remainderDays / 3600
    let remainderHours = remainderDays % 3600
    let minutes = remainderHours / 60
    let seconds = remainderHours % 60
    
    return "\(days)d \(hours)h \(minutes)m \(seconds)s"
}

// MARK: - CalculatorButton
struct CalculatorButton: View {
    let label: String
    var backgroundColor: Color = .gray
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(backgroundColor)
                .cornerRadius(8)
        }
    }
}

// MARK: - ContentView
struct ContentView: View {
    /**
     We'll store typed digits in an array (up to 6 digits for HH:MM:SS).
     This allows a real "backspace" that removes the last digit typed.
    */
    @State private var typedDigits: [Character] = []
    
    @State private var timeEntries: [TimeEntry] = []
    
    // Convert typed digits into a "HH:MM:SS" display
    private var displayTime: String {
        let neededZeros = 6 - typedDigits.count
        let zeros = [Character](repeating: "0", count: neededZeros)
        let raw = zeros + typedDigits  // total 6 chars: e.g. "000028"
        
        let hhString = String(raw[0...1]) // first 2 => hours
        let mmString = String(raw[2...3]) // next 2 => minutes
        let ssString = String(raw[4...5]) // last 2 => seconds
        
        return "\(hhString):\(mmString):\(ssString)"
    }
    
    // Parse typed digits into a TimeEntry
    private var parsedTimeEntry: TimeEntry {
        let neededZeros = 6 - typedDigits.count
        let zeros = [Character](repeating: "0", count: neededZeros)
        let raw = zeros + typedDigits
        
        let hh = Int(String(raw[0...1])) ?? 0
        let mm = Int(String(raw[2...3])) ?? 0
        let ss = Int(String(raw[4...5])) ?? 0
        
        return TimeEntry(days: 0, hours: hh, minutes: mm, seconds: ss)
    }
    
    // Sum of all entries
    private var totalSeconds: Int {
        timeEntries.reduce(0) { $0 + $1.totalSeconds }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Display
                Text(displayTime)
                    .font(.system(size: 36, weight: .bold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // -- Rows 1-3 (4 columns) --
                VStack(spacing: 10) {
                    // Row 1: 7 8 9 ⌫
                    HStack(spacing: 10) {
                        CalculatorButton(label: "7") { handleDigitTap("7") }
                        CalculatorButton(label: "8") { handleDigitTap("8") }
                        CalculatorButton(label: "9") { handleDigitTap("9") }
                        CalculatorButton(label: "⌫", backgroundColor: .orange) {
                            handleBackspace()
                        }
                    }
                    
                    // Row 2: 4 5 6 C
                    HStack(spacing: 10) {
                        CalculatorButton(label: "4") { handleDigitTap("4") }
                        CalculatorButton(label: "5") { handleDigitTap("5") }
                        CalculatorButton(label: "6") { handleDigitTap("6") }
                        CalculatorButton(label: "C", backgroundColor: .red) {
                            handleClear()
                        }
                    }
                    
                    // Row 3: 1 2 3 +
                    HStack(spacing: 10) {
                        CalculatorButton(label: "1") { handleDigitTap("1") }
                        CalculatorButton(label: "2") { handleDigitTap("2") }
                        CalculatorButton(label: "3") { handleDigitTap("3") }
                        CalculatorButton(label: "+", backgroundColor: .green) {
                            handleAdd()
                        }
                    }
                }
                
                // -- Row 4: blank, 0, blank, = --
                HStack(spacing: 10) {
                    CalculatorButton(label: " ", backgroundColor: .clear) {
                        // left blank
                    }
                    
                    CalculatorButton(label: "0") { handleDigitTap("0") }
                    
                    CalculatorButton(label: " ", backgroundColor: .clear) {
                        // middle blank
                    }
                    
                    CalculatorButton(label: "=", backgroundColor: .blue) {
                        handleEquals()
                    }
                }
                .padding(.bottom, 10)
                
                // Show total
                Text("Total: \(formattedTimeString(from: totalSeconds))")
                    .font(.title3)
                
                // (Optional) Clear All History button
                HStack {
                    Spacer()
                    Button("Clear All History") {
                        clearAllHistory()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                    Spacer()
                }
                
                // List of entries
                List {
                    ForEach(timeEntries) { entry in
                        NavigationLink(destination: EditEntryView(entry: entry, onSave: { updated in
                            if let idx = timeEntries.firstIndex(where: { $0.id == entry.id }) {
                                timeEntries[idx] = updated
                            }
                        })) {
                            Text(formattedTimeString(from: entry.totalSeconds))
                        }
                    }
                    .onDelete(perform: deleteEntry)
                }
                .listStyle(.plain)
                
                Spacer()
            }
            .navigationTitle("Time Calculator")
        }
    }
    
    // MARK: - Actions
    
    private func handleDigitTap(_ digit: String) {
        guard let ch = digit.first else { return }
        if typedDigits.count < 6 {
            typedDigits.append(ch)
        }
    }
    
    private func handleBackspace() {
        if !typedDigits.isEmpty {
            typedDigits.removeLast()
        }
    }
    
    private func handleClear() {
        typedDigits.removeAll()
    }
    
    private func handleAdd() {
        timeEntries.append(parsedTimeEntry)
        typedDigits.removeAll()
    }
    
    private func handleEquals() {
        // same as handleAdd (or do something else if you'd like)
        timeEntries.append(parsedTimeEntry)
        typedDigits.removeAll()
    }
    
    private func clearAllHistory() {
        timeEntries.removeAll()
        typedDigits.removeAll()
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        timeEntries.remove(atOffsets: offsets)
    }
}

// MARK: - EditEntryView (Optional)
struct EditEntryView: View {
    @State private var tempDays: String
    @State private var tempHours: String
    @State private var tempMinutes: String
    @State private var tempSeconds: String
    
    let entry: TimeEntry
    let onSave: (TimeEntry) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    init(entry: TimeEntry, onSave: @escaping (TimeEntry) -> Void) {
        self.entry = entry
        self.onSave = onSave
        
        _tempDays = State(initialValue: "\(entry.days)")
        _tempHours = State(initialValue: "\(entry.hours)")
        _tempMinutes = State(initialValue: "\(entry.minutes)")
        _tempSeconds = State(initialValue: "\(entry.seconds)")
    }
    
    var body: some View {
        Form {
            Section(header: Text("Edit Entry")) {
                TextField("Days", text: $tempDays)
                    .keyboardType(.numberPad)
                TextField("Hours", text: $tempHours)
                    .keyboardType(.numberPad)
                TextField("Minutes", text: $tempMinutes)
                    .keyboardType(.numberPad)
                TextField("Seconds", text: $tempSeconds)
                    .keyboardType(.numberPad)
            }
            
            Button("Save") {
                let days = Int(tempDays) ?? 0
                let hours = Int(tempHours) ?? 0
                let minutes = Int(tempMinutes) ?? 0
                let seconds = Int(tempSeconds) ?? 0
                
                let updated = TimeEntry(
                    id: entry.id,
                    days: days,
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds
                )
                
                onSave(updated)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Edit Time Entry")
    }
}
