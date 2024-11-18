import UIKit

class TextViewCell: UITableViewCell {
    
    // MARK: - Properties
    private let customTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .placeholderText
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
        contentView.addSubview(customTextView)
        contentView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            customTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            customTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            placeholderLabel.topAnchor.constraint(equalTo: customTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: customTextView.leadingAnchor, constant: 5)
        ])
        
        customTextView.delegate = self
    }
    
    // MARK: - Configuration
    func configure(with textView: UITextView, placeholder: String) {
        customTextView.text = textView.text
        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = !textView.text.isEmpty
        textView.text = customTextView.text
    }
}

// MARK: - UITextViewDelegate
extension TextViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
} 