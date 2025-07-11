import SwiftUI

// MARK: - Theme Protocol
protocol Theme {
    var accentColor: Color { get }
    var name: String { get }
}

// MARK: - Color Themes
struct OrangeTheme: Theme {
    let accentColor: Color = .orange
    let name: String = "Orange"
}

struct BlueTheme: Theme {
    let accentColor: Color = .blue
    let name: String = "Blue"
}

struct RedTheme: Theme {
    let accentColor: Color = .red
    let name: String = "Red"
}

struct PurpleTheme: Theme {
    let accentColor: Color = .purple
    let name: String = "Purple"
}

struct TealTheme: Theme {
    let accentColor: Color = .teal
    let name: String = "Teal"
}

struct GreenTheme: Theme {
    let accentColor: Color = .green
    let name: String = "Green"
}

struct MagentaTheme: Theme {
    let accentColor: Color = Color(red: 1.0, green: 0.0, blue: 0.5)
    let name: String = "Magenta"
}

// MARK: - Theme Manager
@MainActor
class ThemeManager: ObservableObject {
    @Published private(set) var currentTheme: Theme = BlueTheme()
    
    let availableThemes: [Theme] = [
        OrangeTheme(),
        BlueTheme(),
        RedTheme(),
        PurpleTheme(),
        TealTheme(),
        GreenTheme(),
        MagentaTheme()
    ]
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    init() {
        loadSavedTheme()
    }
    
    func applyTheme(_ theme: Theme) {
        self.currentTheme = theme
        saveTheme(theme)
    }
    
    private func loadSavedTheme() {
        if let savedThemeName = userDefaults.string(forKey: themeKey) {
            if let savedTheme = availableThemes.first(where: { $0.name == savedThemeName }) {
                self.currentTheme = savedTheme
            }
        }
        // If no saved theme or saved theme not found, BlueTheme is already the default
    }
    
    private func saveTheme(_ theme: Theme) {
        userDefaults.set(theme.name, forKey: themeKey)
    }
}

// MARK: - Theme Extensions for Dynamic Colors
extension Theme {
    var background: Color {
        Color(.systemBackground)
    }
    
    var display: Color {
        Color(.label)
    }
    
    var operationButton: Color {
        accentColor
    }
    
    var specialButton: Color {
        Color(.systemGray4)
    }
    
    var numberButton: Color {
        Color(.systemGray5)
    }
    
    var buttonTextPrimary: Color {
        Color(.label)
    }
    
    var buttonTextSecondary: Color {
        Color(.label)
    }
} 