import SwiftUI
import UIKit

enum TimeUnit: String, CaseIterable, Identifiable {
    case seconds = "Seconds"
    case minutes = "Minutes"
    case hours = "Hours"
    case days = "Days"
    
    var id: String { rawValue }
    
    var toSeconds: Double {
        switch self {
        case .seconds: return 1
        case .minutes: return 60
        case .hours: return 3600
        case .days: return 86400
        }
    }
}

struct CalculatorButtonModel: Identifiable {
    let id = UUID()
    let title: String
    let type: ButtonType
    
    enum ButtonType {
        case number(Int)
        case operation(Operation)
        case function(Function)
        
        enum Operation {
            case add, subtract, multiply, divide
        }
        
        enum Function {
            case clear, delete, convert, equals
        }
    }
    
    var backgroundColor: (ColorScheme) -> Color {
        { colorScheme in
            switch type {
            case .number:
                return colorScheme == .dark ? Color(UIColor.systemGray5) : .white
            case .operation:
                return Color.blue
            case .function:
                return colorScheme == .dark ? Color(UIColor.systemGray4) : Color(UIColor.systemGray5)
            }
        }
    }
    
    var foregroundColor: Color {
        switch type {
        case .number:
            return .primary
        case .operation, .function:
            return .white
        }
    }
}

@MainActor
class TimeCalculatorViewModel: ObservableObject {
    @Published var inputValue = "0"
    @Published var result = ""
    @Published var selectedUnit: TimeUnit = .seconds
    
    private var currentOperation: CalculatorButtonModel.ButtonType.Operation?
    private var firstNumber: Double?
    
    let buttons: [CalculatorButtonModel] = [
        CalculatorButtonModel(title: "C", type: .function(.clear)),
        CalculatorButtonModel(title: "⌫", type: .function(.delete)),
        CalculatorButtonModel(title: "=", type: .function(.equals)),
        CalculatorButtonModel(title: "÷", type: .operation(.divide)),
        
        CalculatorButtonModel(title: "7", type: .number(7)),
        CalculatorButtonModel(title: "8", type: .number(8)),
        CalculatorButtonModel(title: "9", type: .number(9)),
        CalculatorButtonModel(title: "×", type: .operation(.multiply)),
        
        CalculatorButtonModel(title: "4", type: .number(4)),
        CalculatorButtonModel(title: "5", type: .number(5)),
        CalculatorButtonModel(title: "6", type: .number(6)),
        CalculatorButtonModel(title: "-", type: .operation(.subtract)),
        
        CalculatorButtonModel(title: "1", type: .number(1)),
        CalculatorButtonModel(title: "2", type: .number(2)),
        CalculatorButtonModel(title: "3", type: .number(3)),
        CalculatorButtonModel(title: "+", type: .operation(.add)),
        
        CalculatorButtonModel(title: "0", type: .number(0)),
        CalculatorButtonModel(title: ".", type: .number(-1)),
        CalculatorButtonModel(title: "Convert", type: .function(.convert))
    ]
    
    func buttonTapped(_ button: CalculatorButtonModel) {
        switch button.type {
        case .number(let number):
            handleNumber(number)
        case .operation(let operation):
            handleOperation(operation)
        case .function(let function):
            handleFunction(function)
        }
        updateResult()
    }
    
    private func handleNumber(_ number: Int) {
        if inputValue == "0" {
            inputValue = number == -1 ? "0." : "\(number)"
        } else {
            if number == -1 && !inputValue.contains(".") {
                inputValue += "."
            } else if number != -1 {
                inputValue += "\(number)"
            }
        }
    }
    
    private func handleOperation(_ operation: CalculatorButtonModel.ButtonType.Operation) {
        if let number = Double(inputValue) {
            if firstNumber == nil {
                firstNumber = number
            } else {
                calculateResult()
            }
            currentOperation = operation
            inputValue = "0"
        }
    }
    
    private func handleFunction(_ function: CalculatorButtonModel.ButtonType.Function) {
        switch function {
        case .clear:
            inputValue = "0"
            firstNumber = nil
            currentOperation = nil
        case .delete:
            if inputValue.count > 1 {
                inputValue.removeLast()
            } else {
                inputValue = "0"
            }
        case .convert:
            convertTime()
        case .equals:
            calculateResult()
        }
    }
    
    private func calculateResult() {
        guard let first = firstNumber,
              let operation = currentOperation,
              let second = Double(inputValue) else { return }
        
        let result: Double
        switch operation {
        case .add:
            result = first + second
        case .subtract:
            result = first - second
        case .multiply:
            result = first * second
        case .divide:
            result = first / second
        }
        
        inputValue = formatNumber(result)
        firstNumber = nil
        currentOperation = nil
    }
    
    private func convertTime() {
        guard let value = Double(inputValue) else { return }
        let seconds = value * selectedUnit.toSeconds
        
        let days = Int(seconds / TimeUnit.days.toSeconds)
        let hours = Int((seconds.truncatingRemainder(dividingBy: TimeUnit.days.toSeconds)) / TimeUnit.hours.toSeconds)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: TimeUnit.hours.toSeconds)) / TimeUnit.minutes.toSeconds)
        let remainingSeconds = Int(seconds.truncatingRemainder(dividingBy: TimeUnit.minutes.toSeconds))
        
        var result = ""
        if days > 0 { result += "\(days)d " }
        if hours > 0 { result += "\(hours)h " }
        if minutes > 0 { result += "\(minutes)m " }
        if remainingSeconds > 0 { result += "\(remainingSeconds)s" }
        
        self.result = result.isEmpty ? "0s" : result
    }
    
    private func updateResult() {
        if let value = Double(inputValue) {
            let seconds = value * selectedUnit.toSeconds
            result = "\(formatNumber(seconds)) seconds"
        }
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", number)
        }
        return String(format: "%.2f", number)
    }
}
 