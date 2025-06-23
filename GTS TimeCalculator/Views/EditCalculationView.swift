import SwiftUI

struct EditCalculationView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var steps: [CalculationStep]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
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
        .colorScheme(themeManager.currentTheme.background == .black ? .dark : .light)
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
} 