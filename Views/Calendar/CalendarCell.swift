import UIKit

final class CalendarCell: UICollectionViewCell {
    
    // MARK: - Properties
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with date: Int, isSelected: Bool = false, isToday: Bool = false) {
        dateLabel.text = "\(date)"
        
        if isSelected {
            contentView.backgroundColor = .systemBlue
            dateLabel.textColor = .white
        } else if isToday {
            contentView.backgroundColor = .systemGray5
            dateLabel.textColor = .label
        } else {
            contentView.backgroundColor = .clear
            dateLabel.textColor = .label
        }
        
        contentView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
        contentView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
        dateLabel.textColor = .label
    }
} 