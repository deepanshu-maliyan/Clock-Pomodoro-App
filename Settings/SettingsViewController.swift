import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        table.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private enum Section: Int, CaseIterable {
        case general
        case sound
        case appearance
        case about
        
        var title: String {
            switch self {
            case .general: return "General"
            case .sound: return "Sound & Haptics"
            case .appearance: return "Appearance"
            case .about: return "About"
            }
        }
    }
    
    private let settings = UserDefaults.standard
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Settings"
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
}

// MARK: - UITableViewDelegate & DataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .general: return 3
        case .sound: return 2
        case .appearance: return 2
        case .about: return 3
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .general:
            return generalCell(for: indexPath)
        case .sound:
            return soundCell(for: indexPath)
        case .appearance:
            return appearanceCell(for: indexPath)
        case .about:
            return aboutCell(for: indexPath)
        case .none:
            return UITableViewCell()
        }
    }
    
    private func generalCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Default Timer Duration"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = "Time Zone"
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.textLabel?.text = "24-Hour Time"
            let switchView = UISwitch()
            switchView.isOn = settings.bool(forKey: "use24HourTime")
            switchView.addTarget(self, action: #selector(timeFormatChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        default:
            break
        }
        return cell
    }
    
    private func soundCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
        switch indexPath.row {
        case 0:
            cell.configure(title: "Sound Effects", key: "soundEnabled")
        case 1:
            cell.configure(title: "Haptic Feedback", key: "hapticsEnabled")
        default:
            break
        }
        return cell
    }
    
    private func appearanceCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Theme"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = "Clock Face Style"
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
        return cell
    }
    
    private func aboutCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Version"
            cell.detailTextLabel?.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        case 1:
            cell.textLabel?.text = "Rate App"
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.textLabel?.text = "Send Feedback"
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .general:
            handleGeneralSelection(at: indexPath)
        case .appearance:
            handleAppearanceSelection(at: indexPath)
        case .about:
            handleAboutSelection(at: indexPath)
        default:
            break
        }
    }
    
    // MARK: - Actions
    @objc private func timeFormatChanged(_ sender: UISwitch) {
        settings.set(sender.isOn, forKey: "use24HourTime")
        NotificationCenter.default.post(name: .timeFormatChanged, object: nil)
    }
    
    private func handleGeneralSelection(at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = TimerSettingsViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = TimeZoneSelectionViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    private func handleAppearanceSelection(at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = ThemeSelectionViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = ClockStyleViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    private func handleAboutSelection(at indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            // Open App Store rating
            if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOURAPPID?action=write-review") {
                UIApplication.shared.open(url)
            }
        case 2:
            // Open email feedback
            if let url = URL(string: "mailto:your@email.com?subject=Productivity%20Clock%20Feedback") {
                UIApplication.shared.open(url)
            }
        default:
            break
        }
    }
}

// MARK: - Custom Cells
class SwitchTableViewCell: UITableViewCell {
    
    private let switchControl: UISwitch = {
        let switchView = UISwitch()
        return switchView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = switchControl
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var settingsKey: String?
    
    func configure(title: String, key: String) {
        textLabel?.text = title
        settingsKey = key
        switchControl.isOn = UserDefaults.standard.bool(forKey: key)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        guard let key = settingsKey else { return }
        UserDefaults.standard.set(sender.isOn, forKey: key)
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let timeFormatChanged = Notification.Name("com.example.app.timeFormatChanged")
} 