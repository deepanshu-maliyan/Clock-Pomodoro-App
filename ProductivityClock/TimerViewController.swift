import UIKit

class TimerViewController: UIViewController {
    
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
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private var isTimerRunning = false
    
    private let hours = Array(0...23)
    private let minutes = Array(0...59)
    private let seconds = Array(0...59)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timer"
        setupUI()
        setupPicker()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(timeLabel)
        view.addSubview(startButton)
        view.addSubview(pickerView)
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 30),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 30),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func startButtonTapped() {
        if isTimerRunning {
            timer?.invalidate()
            startButton.setTitle("Start", for: .normal)
            startButton.backgroundColor = .systemGreen
        } else {
            startTimer()
            startButton.setTitle("Stop", for: .normal)
            startButton.backgroundColor = .systemRed
        }
        isTimerRunning.toggle()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                self.updateDisplay()
            } else {
                self.timer?.invalidate()
                self.startButton.setTitle("Start", for: .normal)
                self.startButton.backgroundColor = .systemGreen
                self.isTimerRunning = false
            }
        }
    }
    
    private func updateDisplay() {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func setupPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
}

extension TimerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3 // Hours, Minutes, Seconds
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return hours.count
        case 1: return minutes.count
        case 2: return seconds.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%02d", row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let hours = pickerView.selectedRow(inComponent: 0)
        let minutes = pickerView.selectedRow(inComponent: 1)
        let seconds = pickerView.selectedRow(inComponent: 2)
        
        remainingSeconds = hours * 3600 + minutes * 60 + seconds
        updateDisplay()
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 60
    }
} 