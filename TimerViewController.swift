import UIKit
import AudioToolbox

class TimerViewController: UIViewController {
    
    // MARK: - Properties
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 70, weight: .bold)
        label.textColor = .label
        label.text = "00:00:00"
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
    
    private let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private var timer: Timer?
    private var isRunning = false
    private var remainingSeconds: TimeInterval = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Timer"
        view.backgroundColor = .systemBackground
        
        view.addSubview(timePicker)
        view.addSubview(timerLabel)
        view.addSubview(startButton)
        view.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            startButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 40),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 40),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        timerLabel.isHidden = true
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
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
    
    @objc private func resetButtonTapped() {
        resetTimer()
    }
    
    // MARK: - Timer Methods
    private func startTimer() {
        startButton.setTitle("Pause", for: .normal)
        startButton.backgroundColor = .systemOrange
        timePicker.isEnabled = false
        timerLabel.isHidden = false
        
        if remainingSeconds == 0 {
            remainingSeconds = timePicker.countDownDuration
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func pauseTimer() {
        startButton.setTitle("Resume", for: .normal)
        startButton.backgroundColor = .systemGreen
        timer?.invalidate()
    }
    
    private func resetTimer() {
        timer?.invalidate()
        isRunning = false
        remainingSeconds = 0
        
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemGreen
        timePicker.isEnabled = true
        timerLabel.isHidden = true
    }
    
    private func updateTimer() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            let hours = Int(remainingSeconds) / 3600
            let minutes = Int(remainingSeconds) / 60 % 60
            let seconds = Int(remainingSeconds) % 60
            timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            timer?.invalidate()
            timerLabel.text = "00:00:00"
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            isRunning = false
            startButton.setTitle("Start", for: .normal)
            startButton.backgroundColor = .systemGreen
            timePicker.isEnabled = true
            timerLabel.isHidden = true
        }
    }
} 