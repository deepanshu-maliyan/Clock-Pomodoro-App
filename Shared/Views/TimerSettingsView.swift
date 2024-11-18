import SwiftUI

struct TimerSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PomodoroViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Pomodoro Duration") {
                    Picker("Minutes", selection: $viewModel.customPomodoroTime) {
                        ForEach(1...60, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                }
                
                Section("Short Break Duration") {
                    Picker("Minutes", selection: $viewModel.customShortBreakTime) {
                        ForEach(1...30, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                }
                
                Section("Long Break Duration") {
                    Picker("Minutes", selection: $viewModel.customLongBreakTime) {
                        ForEach(1...60, id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                }
            }
            .navigationTitle("Timer Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    TimerSettingsView(viewModel: PomodoroViewModel())
} 