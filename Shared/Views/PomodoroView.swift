import SwiftUI
import AVFoundation

struct PomodoroView: View {
    @StateObject private var viewModel = PomodoroViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Mode Selector
            Picker("Mode", selection: $viewModel.mode) {
                Text(PomodoroMode.pomodoro.title).tag(PomodoroMode.pomodoro)
                Text(PomodoroMode.shortBreak.title).tag(PomodoroMode.shortBreak)
                Text(PomodoroMode.longBreak.title).tag(PomodoroMode.longBreak)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Settings Button
            HStack {
                Spacer()
                Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
                .padding(.horizontal)
            }
            
            // Timer Display
            ZStack {
                // Progress Ring
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.blue, style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))
                
                // Time Label
                Text(viewModel.timeString)
                    .font(.system(size: 70, weight: .bold))
            }
            .padding(40)
            
            // Control Buttons
            HStack(spacing: 60) {
                Button(action: viewModel.startPauseTimer) {
                    Text(viewModel.isRunning ? "Pause" : "Start")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(viewModel.isRunning ? Color.orange : Color.green)
                        .cornerRadius(25)
                }
                
                Button(action: viewModel.resetTimer) {
                    Text("Reset")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.gray)
                        .cornerRadius(25)
                }
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            TimerSettingsView(viewModel: viewModel)
        }
        .alert("Time's Up!", isPresented: $viewModel.showCompletion) {
            Button("Continue") {
                viewModel.handleCompletion()
            }
        } message: {
            Text(viewModel.completionMessage)
        }
    }
}

#Preview {
    PomodoroView()
} 