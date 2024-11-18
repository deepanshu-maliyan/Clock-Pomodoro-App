import Foundation

class EventManager {
    static let shared = EventManager()
    
    private let userDefaults = UserDefaults.standard
    private let eventsKey = "savedEvents"
    
    private(set) var events: [Event] = []
    
    private init() {
        loadEvents()
    }
    
    // MARK: - Event Management
    func addEvent(_ event: Event) {
        events.append(event)
        saveEvents()
        NotificationCenter.default.post(name: .eventsDidChange, object: nil)
    }
    
    func updateEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
            saveEvents()
            NotificationCenter.default.post(name: .eventsDidChange, object: nil)
        }
    }
    
    func deleteEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        saveEvents()
        NotificationCenter.default.post(name: .eventsDidChange, object: nil)
    }
    
    func getEvents(for date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }
    
    // MARK: - Persistence
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            userDefaults.set(encoded, forKey: eventsKey)
        }
    }
    
    private func loadEvents() {
        if let data = userDefaults.data(forKey: eventsKey),
           let decoded = try? JSONDecoder().decode([Event].self, from: data) {
            events = decoded
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let eventsDidChange = Notification.Name("eventsDidChange")
} 