import Foundation

struct Event: Codable {
    let id: UUID
    var title: String
    var date: Date
    var duration: TimeInterval
    var notes: String?
    var isCompleted: Bool
    
    init(title: String, date: Date, duration: TimeInterval, notes: String? = nil) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.duration = duration
        self.notes = notes
        self.isCompleted = false
    }
} 