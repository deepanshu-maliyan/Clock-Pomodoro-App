import UIKit

class ClockViewController: UIViewController {
    
    // MARK: - Properties
    private let clockView: AnalogClockView = {
        let view = AnalogClockView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let digitalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeZoneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change Time Zone", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var timer: Timer?
    private var currentTimeZone: TimeZone = .current {
        didSet {
            updateDisplay()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTimer()
        setupActions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Clock"
        view.backgroundColor = .systemBackground
        
        view.addSubview(clockView)
        view.addSubview(digitalTimeLabel)
        view.addSubview(dateLabel)
        view.addSubview(timeZoneButton)
        
        NSLayoutConstraint.activate([
            clockView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clockView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            clockView.widthAnchor.constraint(equalToConstant: 300),
            clockView.heightAnchor.constraint(equalToConstant: 300),
            
            digitalTimeLabel.topAnchor.constraint(equalTo: clockView.bottomAnchor, constant: 30),
            digitalTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            digitalTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: digitalTimeLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            timeZoneButton.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            timeZoneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateDisplay()
        }
    }
    
    private func setupActions() {
        timeZoneButton.addTarget(self, action: #selector(timeZoneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func timeZoneButtonTapped() {
        let alertController = UIAlertController(title: "Select Time Zone", message: nil, preferredStyle: .actionSheet)
        
        let popularTimeZones = [
            "America/New_York",
            "America/Los_Angeles",
            "Europe/London",
            "Europe/Paris",
            "Asia/Tokyo",
            "Asia/Shanghai",
            "Australia/Sydney"
        ]
        
        for identifier in popularTimeZones {
            if let timeZone = TimeZone(identifier: identifier) {
                let action = UIAlertAction(title: formatTimeZoneName(timeZone), style: .default) { [weak self] _ in
                    self?.currentTimeZone = timeZone
                }
                alertController.addAction(action)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = timeZoneButton
            popoverController.sourceRect = timeZoneButton.bounds
        }
        
        present(alertController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func updateDisplay() {
        let date = Date()
        
        // Update digital time
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium
        timeFormatter.timeZone = currentTimeZone
        digitalTimeLabel.text = timeFormatter.string(from: date)
        
        // Update date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateFormatter.timeZone = currentTimeZone
        dateLabel.text = dateFormatter.string(from: date)
        
        // Update analog clock
        clockView.updateTime(date: date, timeZone: currentTimeZone)
    }
    
    private func formatTimeZoneName(_ timeZone: TimeZone) -> String {
        let name = timeZone.identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? ""
        let offset = timeZone.abbreviation() ?? ""
        return "\(name) (\(offset))"
    }
} 