import Foundation

enum PomodoroMode {
    case pomodoro
    case shortBreak
    case longBreak
    
    var title: String {
        switch self {
        case .pomodoro: return "Pomodoro"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
} 