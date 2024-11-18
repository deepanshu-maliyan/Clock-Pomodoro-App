import UIKit

class ClockViewController: UIViewController {
    
    private let clockView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 150
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Clock"
        setupUI()
        startClock()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(clockView)
        clockView.addSubview(timeLabel)
        clockView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            clockView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clockView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            clockView.widthAnchor.constraint(equalToConstant: 300),
            clockView.heightAnchor.constraint(equalToConstant: 300),
            
            timeLabel.centerXAnchor.constraint(equalTo: clockView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: clockView.centerYAnchor, constant: -10),
            
            dateLabel.centerXAnchor.constraint(equalTo: clockView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func startClock() {
        updateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    private func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        timeLabel.text = dateFormatter.string(from: Date())
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    deinit {
        timer?.invalidate()
    }
} 