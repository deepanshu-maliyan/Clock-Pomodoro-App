import UIKit

class EventListViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(EventCell.self, forCellReuseIdentifier: "EventCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let calendarView: CalendarView = {
        let calendar = CalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private var selectedDate = Date()
    private var events: [Event] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupNotifications()
        loadEvents()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Events"
        view.backgroundColor = .systemBackground
        
        view.addSubview(calendarView)
        view.addSubview(tableView)
        
        calendarView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 300),
            
            tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addEventTapped)
        )
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(eventsDidChange),
            name: .eventsDidChange,
            object: nil
        )
    }
    
    // MARK: - Event Management
    private func loadEvents() {
        events = EventManager.shared.getEvents(for: selectedDate)
        tableView.reloadData()
    }
    
    @objc private func eventsDidChange() {
        loadEvents()
    }
    
    @objc private func addEventTapped() {
        let eventForm = EventFormViewController()
        eventForm.delegate = self
        let nav = UINavigationController(rootViewController: eventForm)
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension EventListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.configure(with: events[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let event = events[indexPath.row]
        let eventForm = EventFormViewController(event: event)
        eventForm.delegate = self
        let nav = UINavigationController(rootViewController: eventForm)
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = events[indexPath.row]
            EventManager.shared.deleteEvent(event)
        }
    }
}

// MARK: - CalendarViewDelegate
extension EventListViewController: CalendarViewDelegate {
    func calendarView(_ calendarView: CalendarView, didSelectDate date: Date) {
        selectedDate = date
        loadEvents()
    }
}

// MARK: - EventFormViewControllerDelegate
extension EventListViewController: EventFormViewControllerDelegate {
    func eventFormViewController(_ controller: EventFormViewController, didSaveEvent event: Event) {
        if EventManager.shared.events.contains(where: { $0.id == event.id }) {
            EventManager.shared.updateEvent(event)
        } else {
            EventManager.shared.addEvent(event)
        }
    }
} 