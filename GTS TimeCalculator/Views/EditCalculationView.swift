import SwiftUI

struct EditCalculationView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var steps: [CalculationStep]
    @Binding var label: String
    @Binding var color: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Name")) {
                    TextField("Calculation Name", text: $label)
                }
                Section(header: Text("Color")) {
                    HStack {
                        Picker("Color", selection: $color) {
                            colorPreview("Blue")
                            colorPreview("Red")
                            colorPreview("Orange")
                            colorPreview("Purple")
                            colorPreview("Teal")
                            colorPreview("Green")
                            colorPreview("Magenta")
                        }
                        .pickerStyle(MenuPickerStyle())
                        Spacer()
                        Circle()
                            .fill(colorForName(color))
                            .frame(width: 28, height: 28)
                    }
                }
                ForEach($steps) { $step in
                    HStack {
                        // We will add editing capabilities here later
                        Text(formatSecondsForDisplay(step.seconds))
                        Spacer()
                        if let op = step.operation {
                            Text(op.rawValue)
                        }
                    }
                }
                .onDelete { indices in
                    steps.remove(atOffsets: indices)
                }
            }
            .navigationTitle("Edit Calculation")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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

    private func colorPreview(_ name: String) -> some View {
        HStack {
            Circle()
                .fill(colorForName(name))
                .frame(width: 20, height: 20)
            Text(name)
        }.tag(name)
    }

    private func colorForName(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "teal": return .teal
        case "green": return .green
        case "magenta": return Color(red: 1.0, green: 0.0, blue: 0.5)
        default: return .blue
        }
    }
} 