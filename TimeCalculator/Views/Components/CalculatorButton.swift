import SwiftUI

struct CalculatorButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    let key: String
    let handleKey: (String) -> Void
    
    private var buttonType: ButtonType {
        if ["+", "-", "×", "÷", "="].contains(key) {
            return .operation
        }
        if ["C", "⌫", "%"].contains(key) {
            return .special
        }
        return .number
    }
    
    private enum ButtonType {
        case number, operation, special
    }
    
    var body: some View {
        Button(action: { handleKey(key) }) {
            Text(key)
                .font(.system(size: 32, weight: .medium))
                .frame(width: buttonWidth(key: key), height: buttonHeight())
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .cornerRadius(buttonHeight() / 2)
        }
    }
    
    // MARK: - Theming
    private var foregroundColor: Color {
        switch buttonType {
        case .special:
            return themeManager.currentTheme.buttonTextSecondary
        default:
            return themeManager.currentTheme.buttonTextPrimary
        }
    }
    
    private var backgroundColor: Color {
        switch buttonType {
        case .operation:
            return themeManager.currentTheme.operationButton
        case .special:
            return themeManager.currentTheme.specialButton
        case .number:
            return themeManager.currentTheme.numberButton
        }
    }
    
    // MARK: - Sizing
    private func buttonWidth(key: String) -> CGFloat {
        let spacing: CGFloat = 12
        let totalSpacing: CGFloat = 3 * spacing
        let availableWidth = UIScreen.main.bounds.width - (2 * 12) - totalSpacing
        let baseWidth = availableWidth / 4
        
        if key == "0" {
            return baseWidth * 2 + spacing
        }
        return baseWidth
    }
    
    private func buttonHeight() -> CGFloat {
        let spacing: CGFloat = 12
        let totalSpacing: CGFloat = 3 * spacing
        let availableWidth = UIScreen.main.bounds.width - (2 * 12) - totalSpacing
        return availableWidth / 4
    }
} 