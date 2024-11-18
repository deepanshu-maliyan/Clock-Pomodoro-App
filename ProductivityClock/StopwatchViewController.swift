import UIKit

class StopwatchViewController: UIViewController {
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64, weight: .bold)
        label.textColor = .label
        label.text = "00:00:00"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var isRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Stopwatch"
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(timeLabel)
        view.addSubview(startButton)
        view.addSubview(resetButton)
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            startButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 30),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            resetButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 30),
            resetButton.widthAnchor.constraint(equalToConstant: 100),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func startButtonTapped() {
        if isRunning {
            timer?.invalidate()
            startButton.setTitle("Start", for: .normal)
            startButton.backgroundColor = .systemGreen
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
                self?.elapsedTime += 0.01
                self?.updateDisplay()
            }
            startButton.setTitle("Stop", for: .normal)
            startButton.backgroundColor = .systemRed
        }
        isRunning.toggle()
    }
    
    @objc private func resetButtonTapped() {
        timer?.invalidate()
        elapsedTime = 0
        updateDisplay()
        isRunning = false
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemGreen
    }
    
    private func updateDisplay() {
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime.truncatingRemainder(dividingBy: 60))
        let milliseconds = Int((elapsedTime * 100).truncatingRemainder(dividingBy: 100))
        timeLabel.text = String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
} 