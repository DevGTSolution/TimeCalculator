import SwiftUI
import SwiftData

struct CalculationStep: Identifiable, Equatable, Codable {
    var id = UUID()
    var seconds: Int
    var operation: ContentView.Operation?
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var displayInput = "0"
    @State private var storedSeconds: Int? = nil
    @State private var pendingOperation: Operation? = nil
    @State private var isEnteringNewNumber = true
    
    @State private var history: [TimeEntry] = []
    @State private var showHistory = false
    @State private var showMenu = false
    @State private var showEditSheet = false
    @State private var shouldDismissHistory = false

    @State private var steps: [CalculationStep] = []
    @State private var currentInput: String = "0"

    enum Operation: String, CaseIterable, Codable {
        case add = "+", subtract = "-", multiply = "×", divide = "÷"
    }
    
    let buttons: [[String]] = [
        ["C", "⌫", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", "="]
    ]

    private var displayValue: String {
        let cleanInput = currentInput.filter { ("0"..."9").contains($0) || $0 == "-" }
        guard !cleanInput.isEmpty, cleanInput != "-" else { return "00:00:00" }
        
        let isNegative = cleanInput.hasPrefix("-")
        let absoluteInput = isNegative ? String(cleanInput.dropFirst()) : cleanInput
        
        let padded = absoluteInput.leftPadding(toLength: 6, withPad: "0")
        let hours = Int(padded.prefix(2)) ?? 0
        let minutes = Int(padded.dropFirst(2).prefix(2)) ?? 0
        let seconds = Int(padded.suffix(2)) ?? 0
        
        let sign = isNegative ? "-" : ""
        return "\(sign)\(String(format: "%02d:%02d:%02d", hours, minutes, seconds))"
    }

    private var currentSeconds: Int {
        let cleanInput = currentInput.filter { ("0"..."9").contains($0) || $0 == "-" }
        guard !cleanInput.isEmpty, cleanInput != "-" else { return 0 }

        let isNegative = cleanInput.hasPrefix("-")
        let absoluteInput = isNegative ? String(cleanInput.dropFirst()) : cleanInput

        let padded = absoluteInput.leftPadding(toLength: 6, withPad: "0")
        let hours = Int(padded.prefix(2)) ?? 0
        let minutes = Int(padded.dropFirst(2).prefix(2)) ?? 0
        let seconds = Int(padded.suffix(2)) ?? 0
        
        let totalSeconds = hours * 3600 + minutes * 60 + seconds
        return isNegative ? -totalSeconds : totalSeconds
    }
    
    private var runningCalculationDisplay: String {
        steps.map { step in
            "\(formatSecondsForDisplay(step.seconds)) \(step.operation?.rawValue ?? "")"
        }.joined(separator: " ")
    }
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.background.ignoresSafeArea()
            
            // This ZStack layers the SideMenu and the mainInterface
            ZStack(alignment: .leading) {
                SideMenu(showMenu: $showMenu)
                    .frame(width: 260)
                    .offset(x: showMenu ? 0 : -260) // Slide in/out
                
                mainInterface
                    .cornerRadius(showMenu ? 20.0 : 0.0)
                    .scaleEffect(showMenu ? 0.85 : 1.0)
                    .offset(x: showMenu ? 260 : 0)
                    .disabled(showMenu)
            }
            .onTapGesture {
                if showMenu {
                    withAnimation {
                        showMenu = false
                    }
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(history: $history, onRestoreCalculation: restoreCalculation)
                .environmentObject(themeManager)
        }
        .onChange(of: shouldDismissHistory) { _, newValue in
            if newValue {
                showHistory = false
                shouldDismissHistory = false
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditCalculationView(steps: $steps)
                .environmentObject(themeManager)
        }
    }
    
    var mainInterface: some View {
        VStack(spacing: 12) {
            // Header with Menu button
            HStack {
                Button(action: { withAnimation { showMenu.toggle() } }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title)
                        .foregroundColor(themeManager.currentTheme.display)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Secondary Display (Running Calculation)
            HStack {
                Spacer()
                Text(runningCalculationDisplay)
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.display.opacity(0.7))
                    .padding(.horizontal)
                    .onTapGesture {
                        showEditSheet.toggle()
                    }
            }
            
            // Primary Display
            HStack {
                Spacer()
                Text(displayValue)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(themeManager.currentTheme.display)
                    .padding(.horizontal)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            // Buttons
            VStack(spacing: 12) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { key in
                            CalculatorButton(key: key, handleKey: handleKey)
                        }
                    }
                }
            }
            .padding(.bottom)

            // History Button
            Button(action: { showHistory.toggle() }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(themeManager.currentTheme.display)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
    
    private func handleKey(_ key: String) {
        if let digit = Int(key) {
            handleDigit(digit)
        } else if let op = Operation(rawValue: key) {
            handleOperation(op)
        } else {
            handleSpecialKey(key)
        }
    }
    
    private func handleDigit(_ digit: Int) {
        if currentInput == "0" {
            currentInput = "\(digit)"
        } else if currentInput.count < 6 {
            currentInput.append("\(digit)")
        }
    }
    
    private func handleOperation(_ op: Operation) {
        // Add the current number and the operation as a step
        steps.append(CalculationStep(seconds: currentSeconds, operation: op))
        currentInput = "0" // Reset for next number
    }
    
    private func handleSpecialKey(_ key: String) {
        switch key {
        case "C":
            steps.removeAll()
            currentInput = "0"
        case "⌫":
            if !currentInput.isEmpty && currentInput != "0" {
                currentInput.removeLast()
                if currentInput.isEmpty {
                    currentInput = "0"
                }
            }
        case "%":
             currentInput = formatSeconds(Int(Double(currentSeconds) * 0.01))
        case "=":
            // Add the final number as a step
            steps.append(CalculationStep(seconds: currentSeconds, operation: nil))
            let result = calculateTotal()
            let newEntry = TimeEntry(
                seconds: result,
                label: runningCalculationDisplay + " = \(formatSecondsForDisplay(result))",
                calculationSteps: steps // Store the steps for restoration
            )
            history.insert(newEntry, at: 0)
            modelContext.insert(newEntry)
            
            // Keep the steps visible but set current input to result
            currentInput = formatSeconds(result)
            // Don't clear steps - keep them for continued editing
        default:
            break
        }
    }

    private func calculateTotal() -> Int {
        var total: Double = 0
        var lastOperation: Operation = .add

        for step in steps {
            let value = Double(step.seconds)
            switch lastOperation {
            case .add:
                total += value
            case .subtract:
                total -= value
            case .multiply:
                total *= (value / 3600.0)
            case .divide:
                if value != 0 {
                    total /= (value / 3600.0)
                }
            }
            lastOperation = step.operation ?? .add
        }
        return Int(total)
    }
    
    private func formatSeconds(_ totalSeconds: Int) -> String {
        let isNegative = totalSeconds < 0
        let secondsAbs = abs(totalSeconds)
        let hours = secondsAbs / 3600
        let minutes = (secondsAbs % 3600) / 60
        let seconds = secondsAbs % 60
        let sign = isNegative ? "-" : ""
        let formatted = String(format: "%02d%02d%02d", hours, minutes, seconds)
        return "\(sign)\(formatted)"
    }

    private func formatSecondsForDisplay(_ totalSeconds: Int) -> String {
        let isNegative = totalSeconds < 0
        let secondsAbs = abs(totalSeconds)
        let hours = secondsAbs / 3600
        let minutes = (secondsAbs % 3600) / 60
        let seconds = secondsAbs % 60
        let sign = isNegative ? "-" : ""
        return "\(sign)\(String(format: "%02d:%02d:%02d", hours, minutes, seconds))"
    }

    private func restoreCalculation(_ steps: [CalculationStep]) {
        self.steps = steps
        if let lastStep = steps.last {
            currentInput = formatSeconds(lastStep.seconds)
        } else {
            currentInput = "0"
        }
        shouldDismissHistory = true
    }
}

// MARK: - Side Menu
struct SideMenu: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var showMenu: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Select Theme")
                .font(.title2)
                .bold()
                .padding()
                .padding(.top, 40)

            Text("Light/Dark mode follows your system settings")
                .font(.caption)
                .foregroundColor(themeManager.currentTheme.display.opacity(0.7))
                .padding(.horizontal)

            ForEach(themeManager.availableThemes, id: \.name) { theme in
                Button(theme.name) {
                    themeManager.applyTheme(theme)
                    withAnimation { showMenu = false }
                }
                .padding()
                .foregroundColor(themeManager.currentTheme.name == theme.name ? themeManager.currentTheme.operationButton : themeManager.currentTheme.display)
            }

            Spacer()
            
            // Copyright notice
            VStack(alignment: .center, spacing: 4) {
                Text("© 2025 GTSolution.pro")
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.display.opacity(0.6))
                Text("All rights reserved")
                    .font(.caption2)
                    .foregroundColor(themeManager.currentTheme.display.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.background)
        .foregroundColor(themeManager.currentTheme.display)
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - History View
struct HistoryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var history: [TimeEntry]
    let onRestoreCalculation: ([CalculationStep]) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(history) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(entry.label)
                                .font(.headline)
                            Text(entry.date, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .onTapGesture {
                        onRestoreCalculation(entry.calculationSteps)
                    }
                }
                .onDelete { indices in
                    history.remove(atOffsets: indices)
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        history.removeAll()
                    }
                }
            }
        }
        .colorScheme(themeManager.currentTheme.background == .black ? .dark : .light)
    }
}

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
        .modelContainer(for: TimeEntry.self, inMemory: true)
} 
