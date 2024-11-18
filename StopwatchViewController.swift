import UIKit

class StopwatchViewController: UIViewController {
    
    // MARK: - Properties
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 70, weight: .bold)
        label.textColor = .label
        label.text = "00:00.00"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let lapButton: UIButton = {
        let button = UIButton()
        button.setTitle("Lap", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 25
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "LapCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var timer: Timer?
    private var isRunning = false
    private var elapsedTime: TimeInterval = 0
    private var laps: [TimeInterval] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Stopwatch"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(timeLabel)
        view.addSubview(startButton)
        view.addSubview(lapButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            startButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 40),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            lapButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 40),
            lapButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            lapButton.widthAnchor.constraint(equalToConstant: 120),
            lapButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        lapButton.addTarget(self, action: #selector(lapButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func startButtonTapped() {
        isRunning.toggle()
        
        if isRunning {
            startTimer()
        } else {
            pauseTimer()
        }
    }
    
    @objc private func lapButtonTapped() {
        laps.insert(elapsedTime, at: 0)
        tableView.reloadData()
    }
    
    // MARK: - Timer Methods
    private func startTimer() {
        startButton.setTitle("Stop", for: .normal)
        startButton.backgroundColor = .systemRed
        lapButton.isEnabled = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func pauseTimer() {
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemGreen
        timer?.invalidate()
        
        if elapsedTime > 0 {
            startButton.setTitle("Reset", for: .normal)
            startButton.backgroundColor = .systemGray
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        isRunning = false
        elapsedTime = 0
        laps.removeAll()
        
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemGreen
        lapButton.isEnabled = false
        timeLabel.text = "00:00.00"
        tableView.reloadData()
    }
    
    private func updateTimer() {
        elapsedTime += 0.01
        updateDisplay()
    }
    
    private func updateDisplay() {
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        let hundredths = Int((elapsedTime * 100).truncatingRemainder(dividingBy: 100))
        
        timeLabel.text = String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        let hundredths = Int((time * 100).truncatingRemainder(dividingBy: 100))
        
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension StopwatchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LapCell", for: indexPath)
        let lapTime = laps[indexPath.row]
        let lapNumber = laps.count - indexPath.row
        
        cell.textLabel?.text = "Lap \(lapNumber)    \(formatTime(lapTime))"
        cell.textLabel?.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
        
        return cell
    }
} 