import UIKit

class TimeZoneSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "TimeZoneCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var timeZones: [TimeZone] = []
    private var filteredTimeZones: [TimeZone] = []
    private let settings = UserDefaults.standard
    
    private var isSearching: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimeZones()
        setupUI()
        setupSearchController()
    }
    
    // MARK: - Setup
    private func setupTimeZones() {
        timeZones = TimeZone.knownTimeZoneIdentifiers.compactMap { TimeZone(identifier: $0) }
        timeZones.sort { formatTimeZoneName($0) < formatTimeZoneName($1) }
    }
    
    private func setupUI() {
        title = "Time Zone"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Time Zones"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Helper Methods
    private func formatTimeZoneName(_ timeZone: TimeZone) -> String {
        let name = timeZone.identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? ""
        let offset = timeZone.abbreviation() ?? ""
        return "\(name) (\(offset))"
    }
    
    private func filterTimeZones(for searchText: String) {
        filteredTimeZones = timeZones.filter { timeZone in
            let name = formatTimeZoneName(timeZone).lowercased()
            return name.contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TimeZoneSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredTimeZones.count : timeZones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeZoneCell", for: indexPath)
        let timeZone = isSearching ? filteredTimeZones[indexPath.row] : timeZones[indexPath.row]
        
        cell.textLabel?.text = formatTimeZoneName(timeZone)
        cell.accessoryType = timeZone.identifier == settings.string(forKey: "selectedTimeZone") ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTimeZone = isSearching ? filteredTimeZones[indexPath.row] : timeZones[indexPath.row]
        settings.set(selectedTimeZone.identifier, forKey: "selectedTimeZone")
        tableView.reloadData()
        
        NotificationCenter.default.post(name: .timeZoneChanged, object: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension TimeZoneSelectionViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filterTimeZones(for: searchText)
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let timeZoneChanged = Notification.Name("timeZoneChanged")
} 