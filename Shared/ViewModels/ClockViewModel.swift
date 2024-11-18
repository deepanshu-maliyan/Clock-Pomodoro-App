import Foundation

class ClockViewModel: ObservableObject {
    @Published var currentTime = Date()
    @Published var timeZone = TimeZone.current
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentTime = Date()
        }
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.timeZone = timeZone
        return formatter.string(from: currentTime)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = timeZone
        return formatter.string(from: currentTime)
    }
    
    deinit {
        timer?.invalidate()
    }
} 