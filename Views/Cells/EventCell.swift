import UIKit

class EventCell: UITableViewCell {
    
    // MARK: - Properties
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let notesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(statusIndicator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(durationLabel)
        containerView.addSubview(notesLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            statusIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            durationLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 16),
            durationLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),
            
            notesLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            notesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            notesLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            notesLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        // Add shadow to container
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.masksToBounds = false
    }
    
    // MARK: - Configuration
    func configure(with event: Event) {
        titleLabel.text = event.title
        
        // Format time
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeLabel.text = timeFormatter.string(from: event.date)
        
        // Format duration
        let hours = Int(event.duration) / 3600
        let minutes = Int(event.duration) / 60 % 60
        if hours > 0 {
            durationLabel.text = "\(hours)h \(minutes)m"
        } else {
            durationLabel.text = "\(minutes)m"
        }
        
        // Set notes if available
        if let notes = event.notes, !notes.isEmpty {
            notesLabel.text = notes
            notesLabel.isHidden = false
        } else {
            notesLabel.isHidden = true
        }
        
        // Update status indicator
        updateStatusIndicator(for: event)
    }
    
    private func updateStatusIndicator(for event: Event) {
        let now = Date()
        
        if event.isCompleted {
            statusIndicator.backgroundColor = .systemGreen
        } else if event.date > now {
            statusIndicator.backgroundColor = .systemBlue
        } else if event.date.addingTimeInterval(event.duration) < now {
            statusIndicator.backgroundColor = .systemRed
        } else {
            statusIndicator.backgroundColor = .systemOrange
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure shadow path is updated
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
            cornerRadius: containerView.layer.cornerRadius
        ).cgPath
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update shadow for dark mode
        if traitCollection.userInterfaceStyle == .dark {
            containerView.layer.shadowOpacity = 0.3
        } else {
            containerView.layer.shadowOpacity = 0.1
        }
    }
} 