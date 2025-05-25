import SwiftUI

struct CalculatorEntry: Identifiable, Equatable {
    let id = UUID()
    var hours: Int
    var minutes: Int
    var seconds: Int
}

struct ContentView: View {
    @State private var input = "" // Raw digits, e.g. "222"
    @State private var lastResult: String? = nil
    @State private var pendingOperation: Operation? = nil
    @State private var storedSeconds: Int? = nil
    @State private var history: [CalculatorEntry] = []
    
    enum Operation: String { case add = "+", subtract = "-", multiply = "×", divide = "÷" }
    
    // Right-to-left: seconds, minutes, hours
    private var hours: Int {
        let padded = input.leftPadding(toLength: 6, withPad: "0")
        return Int(padded.prefix(2)) ?? 0
    }
    private var minutes: Int {
        let padded = input.leftPadding(toLength: 6, withPad: "0")
        return Int(padded.dropFirst(2).prefix(2)) ?? 0
    }
    private var seconds: Int {
        let padded = input.leftPadding(toLength: 6, withPad: "0")
        return Int(padded.suffix(2)) ?? 0
    }
    
    private var formatted: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }
    
    // Running total of all history entries
    private var totalHistorySeconds: Int {
        history.reduce(0) { $0 + $1.hours * 3600 + $1.minutes * 60 + $1.seconds }
    }
    private var totalHistoryFormatted: String {
        let h = totalHistorySeconds / 3600
        let m = (totalHistorySeconds % 3600) / 60
        let s = totalHistorySeconds % 60
        return String(format: "%02d:%02d:%02d  (%dh %dm %ds)", h, m, s, h, m, s)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer(minLength: 24)
                Text(formatted)
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("\(hours)h \(minutes)m \(seconds)s")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if let result = lastResult {
                    Text(result)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)
                }
                
                Spacer()
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                    ForEach(keypadButtons, id: \ .self) { key in
                        Button(action: { handleKey(key) }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(key.isOperator ? Color.accentColor : Color(.systemGray5))
                                if key == "⌫" {
                                    Image(systemName: "delete.left")
                                        .font(.title)
                                        .foregroundColor(key.isOperator ? .white : .primary)
                                } else {
                                    Text(key)
                                        .font(.title)
                                        .fontWeight(key.isOperator ? .bold : .regular)
                                        .foregroundColor(key.isOperator ? .white : .primary)
                                }
                            }
                            .frame(height: 60)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // History Section
                if !history.isEmpty {
                    Text("Total: \(totalHistoryFormatted)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("History")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    List {
                        ForEach(history) { entry in
                            HStack {
                                Text(String(format: "%02d:%02d:%02d", entry.hours, entry.minutes, entry.seconds))
                                    .font(.system(.title3, design: .monospaced))
                                Text("(\(entry.hours)h \(entry.minutes)m \(entry.seconds)s)")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button {
                                    // Edit: load entry into input
                                    input = String(format: "%d%02d%02d", entry.hours, entry.minutes, entry.seconds)
                                } label: {
                                    Image(systemName: "pencil")
                                }
                                Button {
                                    // Delete: remove entry
                                    if let idx = history.firstIndex(of: entry) {
                                        history.remove(at: idx)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                        .onDelete { indices in
                            history.remove(atOffsets: indices)
                        }
                    }
                    .frame(height: min(CGFloat(history.count) * 56, 300))
                    .listStyle(.plain)
                    .padding(.horizontal, -20)
                    .padding(.bottom, 32)
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 32)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var keypadButtons: [String] {
        ["7","8","9","÷",
         "4","5","6","×",
         "1","2","3","-",
         "0","⌫","C","+",
         "="]
    }
    
    private func handleKey(_ key: String) {
        switch key {
        case "C":
            input = ""
            lastResult = nil
            pendingOperation = nil
        case "⌫":
            if !input.isEmpty { input.removeLast() }
        case "+":
            // Add to history
            let entry = CalculatorEntry(hours: hours, minutes: minutes, seconds: seconds)
            history.append(entry)
            input = ""
            lastResult = nil
            pendingOperation = nil
            storedSeconds = nil
        case "=":
            // Add to history and clear input (acts as "done")
            let entry = CalculatorEntry(hours: hours, minutes: minutes, seconds: seconds)
            history.append(entry)
            input = ""
            lastResult = nil
            pendingOperation = nil
            storedSeconds = nil
        case "-", "×", "÷":
            if pendingOperation == nil {
                storedSeconds = totalSeconds
                input = ""
                pendingOperation = Operation(rawValue: key)
            } else if let op = pendingOperation, let lhs = storedSeconds {
                let rhs = totalSeconds
                let result = calculate(lhs: lhs, rhs: rhs, op: op)
                lastResult = formatResult(seconds: result)
                storedSeconds = result
                input = ""
                pendingOperation = Operation(rawValue: key)
            }
        default:
            if input.count < 6, key.allSatisfy({ $0.isNumber }) {
                input.append(key)
            }
        }
    }
    
    private func calculate(lhs: Int, rhs: Int, op: Operation) -> Int {
        switch op {
        case .add: return lhs + rhs
        case .subtract: return max(lhs - rhs, 0)
        case .multiply: return lhs * rhs
        case .divide: return rhs == 0 ? 0 : lhs / rhs
        }
    }
    
    private func formatResult(seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d  (%dh %dm %ds)", h, m, s, h, m, s)
    }
}

private extension String {
    var isOperator: Bool { ["+","-","×","÷"].contains(self) }
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        if self.count < toLength {
            return String(repeatElement(character, count: toLength - self.count)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

#Preview {
    ContentView()
}
