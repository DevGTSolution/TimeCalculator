import SwiftUI

//struct EditEntryView: View {
//    // We make a copy of the entry, so we don’t alter the original until we tap Save
//    @State var tempDays: String
//    @State var tempHours: String
//    @State var tempMinutes: String
//    @State var tempSeconds: String
//    
//    // Original entry to be edited
//    let entry: TimeEntry
//    
//    // Callback to pass updated entry back
//    let onSave: (TimeEntry) -> Void
//    
//    // We can use an Environment variable to dismiss the view on Save
//    @Environment(\.presentationMode) var presentationMode
//    
//    init(entry: TimeEntry, onSave: @escaping (TimeEntry) -> Void) {
//        self.entry = entry
//        self.onSave = onSave
//        // Initialize the editing fields with the entry's values
//        _tempDays = State(initialValue: "\(entry.days)")
//        _tempHours = State(initialValue: "\(entry.hours)")
//        _tempMinutes = State(initialValue: "\(entry.minutes)")
//        _tempSeconds = State(initialValue: "\(entry.seconds)")
//    }
//    
//    var body: some View {
//        Form {
//            Section(header: Text("Edit Entry")) {
//                TextField("Days", text: $tempDays)
//                    .keyboardType(.numberPad)
//                TextField("Hours", text: $tempHours)
//                    .keyboardType(.numberPad)
//                TextField("Minutes", text: $tempMinutes)
//                    .keyboardType(.numberPad)
//                TextField("Seconds", text: $tempSeconds)
//                    .keyboardType(.numberPad)
//            }
//            
//            Button("Save") {
//                // Convert new values to integers safely
//                let days = Int(tempDays) ?? 0
//                let hours = Int(tempHours) ?? 0
//                let minutes = Int(tempMinutes) ?? 0
//                let seconds = Int(tempSeconds) ?? 0
//                
//                let updatedEntry = TimeEntry(
//                    id: entry.id,           // pass in the old ID
//                    days: days,
//                    hours: hours,
//                    minutes: minutes,
//                    seconds: seconds
//                )
//                
//                // Call onSave closure
//                onSave(updatedEntry)
//                
//                // Dismiss view
//                presentationMode.wrappedValue.dismiss()
//            }
//        }
//        .navigationTitle("Edit Time Entry")
//    }
//}
//Test for Xcode
