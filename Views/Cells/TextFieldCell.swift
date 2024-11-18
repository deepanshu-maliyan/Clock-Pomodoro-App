import UIKit

class TextFieldCell: UITableViewCell {
    
    // MARK: - Properties
    private let customTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        contentView.addSubview(customTextField)
        
        NSLayoutConstraint.activate([
            customTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            customTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with textField: UITextField, placeholder: String) {
        customTextField.text = textField.text
        customTextField.placeholder = placeholder
        customTextField.delegate = textField.delegate
        textField.text = customTextField.text
    }
} 