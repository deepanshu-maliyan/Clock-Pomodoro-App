import UIKit

class ClockStyleViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(ClockStyleCell.self, forCellReuseIdentifier: "ClockStyleCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private enum ClockStyle: Int, CaseIterable {
        case classic
        case modern
        case minimal
        case digital
        
        var title: String {
            switch self {
            case .classic: return "Classic"
            case .modern: return "Modern"
            case .minimal: return "Minimal"
            case .digital: return "Digital"
            }
        }
        
        var description: String {
            switch self {
            case .classic: return "Traditional analog clock with numbers"
            case .modern: return "Sleek design with line markers"
            case .minimal: return "Simple and clean look"
            case .digital: return "Digital time display only"
            }
        }
        
        var previewImage: UIImage? {
            return UIImage(named: "clock_style_\(self)")
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
        title = "Clock Face Style"
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
extension ClockStyleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ClockStyle.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClockStyleCell", for: indexPath) as! ClockStyleCell
        let style = ClockStyle(rawValue: indexPath.row)!
        
        cell.configure(with: style)
        cell.accessoryType = settings.integer(forKey: "selectedClockStyle") == indexPath.row ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        settings.set(indexPath.row, forKey: "selectedClockStyle")
        tableView.reloadData()
        
        NotificationCenter.default.post(name: .clockStyleChanged, object: nil)
    }
}

// MARK: - Custom Cell
class ClockStyleCell: UITableViewCell {
    
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(previewImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            previewImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            previewImageView.widthAnchor.constraint(equalToConstant: 60),
            previewImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
    }
    
    func configure(with style: ClockStyle) {
        titleLabel.text = style.title
        descriptionLabel.text = style.description
        previewImageView.image = style.previewImage
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let clockStyleChanged = Notification.Name("clockStyleChanged")
} 