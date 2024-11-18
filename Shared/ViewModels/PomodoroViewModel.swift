import Foundation
import AVFoundation

class PomodoroViewModel: ObservableObject {
    @Published var mode: PomodoroMode = .pomodoro
    @Published var isRunning = false
    @Published var progress: Double = 1.0
    @Published var showSettings = false
    @Published var showCompletion = false
    
    @Published var customPomodoroTime: Int = 25
    @Published var customShortBreakTime: Int = 5
    @Published var customLongBreakTime: Int = 15
    
    private var timer: Timer?
    private var remainingSeconds: Int
    
    var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var completionMessage: String {
        switch mode {
        case .pomodoro:
            return "Great job! Time for a break."
        case .shortBreak:
            return "Short break is over. Ready to focus again?"
        case .longBreak:
            return "Long break is over. Ready to start a new session?"
        }
    }
    
    init() {
        remainingSeconds = customPomodoroTime * 60
    }
    
    func startPauseTimer() {
        isRunning.toggle()
        
        if isRunning {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
        } else {
            timer?.invalidate()
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        isRunning = false
        updateRemainingTime()
        progress = 1.0
    }
    
    private func updateTimer() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateProgress()
        } else {
            timer?.invalidate()
            isRunning = false
            playCompletionSound()
            showCompletion = true
        }
    }
    
    private func updateProgress() {
        let totalTime = getTotalTime()
        progress = Double(remainingSeconds) / Double(totalTime)
    }
    
    private func updateRemainingTime() {
        remainingSeconds = getTotalTime()
    }
    
    private func getTotalTime() -> Int {
        switch mode {
        case .pomodoro:
            return customPomodoroTime * 60
        case .shortBreak:
            return customShortBreakTime * 60
        case .longBreak:
            return customLongBreakTime * 60
        }
    }
    
    func handleCompletion() {
        switch mode {
        case .pomodoro:
            mode = .shortBreak
        case .shortBreak, .longBreak:
            mode = .pomodoro
        }
        resetTimer()
    }
    
    private func playCompletionSound() {
        AudioServicesPlaySystemSound(1005)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(1023)
        }
    }
} 