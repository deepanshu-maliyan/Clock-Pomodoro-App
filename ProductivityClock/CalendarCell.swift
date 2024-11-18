import UIKit

class CalendarCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with text: String, isHeader: Bool) {
        label.text = text
        if isHeader {
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .secondaryLabel
        } else {
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textColor = .label
            
            // Highlight today's date
            if let today = Calendar.current.dateComponents([.day], from: Date()).day,
               text == "\(today)" {
                contentView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
                contentView.layer.cornerRadius = 12
            } else {
                contentView.backgroundColor = .clear
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
    }
} 