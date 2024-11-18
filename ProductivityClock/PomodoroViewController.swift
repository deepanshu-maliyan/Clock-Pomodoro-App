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
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let timePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.isHidden = true
        return picker
    }()
    
    private let modeSegmentControl: UISegmentedControl = {
        let items = ["Pomodoro", "Short Break", "Long Break"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // Timer properties
    private var timer: Timer?
    private var remainingSeconds: Int = 25 * 60
    private var isTimerRunning = false
    
    // Custom time properties
    private var customPomodoroTime: Int = 25
    private var customShortBreakTime: Int = 5
    private var customLongBreakTime: Int = 15
    private let minuteOptions = Array(1...60)
    private var currentEditingTimer: TimerType?
    
    private enum TimerType {
        case pomodoro
        case shortBreak
        case longBreak
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pomodoro"
        setupUI()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupProgressRings()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(modeSegmentControl)
        view.addSubview(timerLabel)
        view.addSubview(startButton)
        view.addSubview(resetButton)
        view.addSubview(settingsButton)
        view.addSubview(timePickerView)
        
        timePickerView.delegate = self
        timePickerView.dataSource = self
        
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
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            
            timePickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            timePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timePickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupProgressRings() {
        // Calculate center point relative to timerLabel
        let centerX = view.bounds.midX
        let centerY = timerLabel.center.y
        let center = CGPoint(x: centerX, y: centerY)
        
        // Make the radius larger to encircle the timer
        let radius = min(
            view.bounds.width * 0.35, // 35% of screen width
            180.0 // Minimum radius
        )
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        // Remove existing layers if they exist
        progressRing.removeFromSuperlayer()
        backgroundRing.removeFromSuperlayer()
        
        // Update paths
        backgroundRing.path = circularPath.cgPath
        progressRing.path = circularPath.cgPath
        
        // Add layers in correct order
        view.layer.insertSublayer(backgroundRing, below: timerLabel.layer)
        view.layer.insertSublayer(progressRing, below: timerLabel.layer)
        
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
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    @objc private func resetButtonTapped() {
        resetTimer()
    }
    
    @objc private func modeChanged() {
        resetTimer()
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
    }
    
    @objc private func settingsButtonTapped() {
        showTimeSettingsAlert()
    }
    
    private func showTimeSettingsAlert() {
        let alert = UIAlertController(title: "Timer Settings", 
                                    message: "Adjust timer duration (minutes)", 
                                    preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Pomodoro Time", style: .default) { [weak self] _ in
            self?.showTimePicker(for: .pomodoro)
        })
        
        alert.addAction(UIAlertAction(title: "Short Break", style: .default) { [weak self] _ in
            self?.showTimePicker(for: .shortBreak)
        })
        
        alert.addAction(UIAlertAction(title: "Long Break", style: .default) { [weak self] _ in
            self?.showTimePicker(for: .longBreak)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showTimePicker(for timerType: TimerType) {
        currentEditingTimer = timerType
        timePickerView.isHidden = false
        
        let currentValue: Int
        switch timerType {
        case .pomodoro:
            currentValue = customPomodoroTime
        case .shortBreak:
            currentValue = customShortBreakTime
        case .longBreak:
            currentValue = customLongBreakTime
        }
        
        if let index = minuteOptions.firstIndex(of: currentValue) {
            timePickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    // MARK: - Timer Methods
    private func startTimer() {
        startButton.setTitle("Pause", for: .normal)
        startButton.backgroundColor = .systemOrange
        isTimerRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        startButton.setTitle("Resume", for: .normal)
        startButton.backgroundColor = .systemGreen
        isTimerRunning = false
    }
    
    private func resetTimer() {
        timer?.invalidate()
        startButton.setTitle("Start", for: .normal)
        startButton.backgroundColor = .systemGreen
        isTimerRunning = false
        
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
    
    private func updateTimer() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateDisplay()
            updateProgress()
        } else {
            timer?.invalidate()
            playCompletionSound()
            showCompletionAlert()
        }
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
            totalTime = Double(customPomodoroTime * 60)
        }
        
        let progress = Double(remainingSeconds) / totalTime
        progressRing.strokeEnd = CGFloat(progress)
    }
    
    private func playCompletionSound() {
        // Try different combinations of sounds
        playSystemSound(SystemSounds.alert)
        AudioServicesPlaySystemSound(SystemSounds.vibrate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.playSystemSound(SystemSounds.notification)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.playSystemSound(SystemSounds.calendar)
        }
    }
    
    private func showCompletionAlert() {
        let alert = UIAlertController(
            title: "Time's Up!", 
            message: getCompletionMessage(),
            preferredStyle: .alert
        )
        
        // Add continue action
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.handleTimerCompletion()
        })
        
        present(alert, animated: true)
    }
    
    private func getCompletionMessage() -> String {
        switch modeSegmentControl.selectedSegmentIndex {
        case 0:
            return "Great job! Time for a break."
        case 1:
            return "Short break is over. Ready to focus again?"
        case 2:
            return "Long break is over. Ready to start a new session?"
        default:
            return "Timer completed!"
        }
    }
    
    private func handleTimerCompletion() {
        // Automatically switch to the next appropriate mode
        switch modeSegmentControl.selectedSegmentIndex {
        case 0: // After Pomodoro
            modeSegmentControl.selectedSegmentIndex = 1 // Switch to short break
        case 1: // After short break
            modeSegmentControl.selectedSegmentIndex = 0 // Back to Pomodoro
        case 2: // After long break
            modeSegmentControl.selectedSegmentIndex = 0 // Back to Pomodoro
        default:
            break
        }
        
        // Reset timer for the new mode
        resetTimer()
    }
    
    // Optional: Add this method to try different system sounds
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    // Here are some common system sound IDs you can try:
    private enum SystemSounds {
        static let basic = SystemSoundID(1000)
        static let alert = SystemSoundID(1005)
        static let notification = SystemSoundID(1023)
        static let calendar = SystemSoundID(1016)
        static let mail = SystemSoundID(1007)
        static let screenshot = SystemSoundID(1004)
        static let vibrate = kSystemSoundID_Vibrate
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension PomodoroViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return minuteOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(minuteOptions[row]) minutes"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedMinutes = minuteOptions[row]
        
        guard let timerType = currentEditingTimer else { return }
        
        switch timerType {
        case .pomodoro:
            customPomodoroTime = selectedMinutes
            if modeSegmentControl.selectedSegmentIndex == 0 {
                remainingSeconds = selectedMinutes * 60
                updateDisplay()
            }
        case .shortBreak:
            customShortBreakTime = selectedMinutes
            if modeSegmentControl.selectedSegmentIndex == 1 {
                remainingSeconds = selectedMinutes * 60
                updateDisplay()
            }
        case .longBreak:
            customLongBreakTime = selectedMinutes
            if modeSegmentControl.selectedSegmentIndex == 2 {
                remainingSeconds = selectedMinutes * 60
                updateDisplay()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.timePickerView.isHidden = true
        }
    }
} 