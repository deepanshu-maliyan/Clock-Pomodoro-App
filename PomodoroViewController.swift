import UIKit
import AudioToolbox

class PomodoroViewController: UIViewController {
    
    // MARK: - Properties
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 70, weight: .bold)
        label.textColor = .label
        label.text = "25:00"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressRing: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemBlue.cgColor
        layer.lineWidth = 20
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        return layer
    }()
    
    private let backgroundRing: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemGray5.cgColor
        layer.lineWidth = 20
        layer.fillColor = UIColor.clear.cgColor
        return layer
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
    
    private let modeSegmentControl: UISegmentedControl = {
        let items = ["Pomodoro", "Short Break", "Long Break"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Timer properties
    private var timer: Timer?
    private var isRunning = false
    private var remainingSeconds = 25 * 60
    private var customPomodoroTime = 25
    private var customShortBreakTime = 5
    private var customLongBreakTime = 15
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupProgressRings()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Pomodoro"
        view.backgroundColor = .systemBackground
        
        view.addSubview(modeSegmentControl)
        view.addSubview(timerLabel)
        view.addSubview(startButton)
        view.addSubview(resetButton)
        view.addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            modeSegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            modeSegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            modeSegmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            settingsButton.topAnchor.constraint(equalTo: modeSegmentControl.bottomAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            startButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 140),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 120),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 140),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupProgressRings() {
        let center = CGPoint(x: view.bounds.midX, y: timerLabel.center.y)
        let radius = min(view.bounds.width * 0.35, 180.0)
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        progressRing.removeFromSuperlayer()
        backgroundRing.removeFromSuperlayer()
        
        backgroundRing.path = circularPath.cgPath
        progressRing.path = circularPath.cgPath
        
        view.layer.addSublayer(backgroundRing)
        view.layer.addSublayer(progressRing)
        
        progressRing.strokeEnd = 1
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        modeSegmentControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func startButtonTapped() {
        isRunning.toggle()
        
        if isRunning {
            startButton.setTitle("Pause", for: .normal)
            startButton.backgroundColor = .systemOrange
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
        } else {
            startButton.setTitle("Resume", for: .normal)
            startButton.backgroundColor = .systemGreen
            timer?.invalidate()
        }
    }
    
    @objc private func resetButtonTapped() {
        resetTimer()
    }
    
    @objc private func modeChanged() {
        resetTimer()
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = TimerSettingsViewController()
        settingsVC.delegate = self
        settingsVC.pomodoroTime = customPomodoroTime
        settingsVC.shortBreakTime = customShortBreakTime
        settingsVC.longBreakTime = customLongBreakTime
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
    
    // MARK: - Timer Methods
    private func updateTimer() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateDisplay()
            updateProgress()
        } else {
            timer?.invalidate()
            isRunning = false
            playCompletionSound()
            showCompletionAlert()
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemGreen
        isRunning = false
        
        switch modeSegmentControl.selectedSegmentIndex {
        case 0:
            remainingSeconds = customPomodoroTime * 60
        case 1:
            remainingSeconds = customShortBreakTime * 60
        case 2:
            remainingSeconds = customLongBreakTime * 60
        default:
            break
        }
        
        updateDisplay()
        progressRing.strokeEnd = 1
    }
    
    private func updateDisplay() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func updateProgress() {
        let totalTime: Double
        switch modeSegmentControl.selectedSegmentIndex {
        case 0:
            totalTime = Double(customPomodoroTime * 60)
        case 1:
            totalTime = Double(customShortBreakTime * 60)
        case 2:
            totalTime = Double(customLongBreakTime * 60)
        default:
            break
        }
        
        let progress = 1 - (Double(remainingSeconds) / totalTime)
        progressRing.strokeEnd = CGFloat(progress)
    }
    
    private func playCompletionSound() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(title: "Pomodoro Completed", message: "Time to take a break!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
} 