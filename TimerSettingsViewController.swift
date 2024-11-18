import UIKit

protocol TimerSettingsViewControllerDelegate: AnyObject {
    func didUpdateTimerSettings(pomodoro: Int, shortBreak: Int, longBreak: Int)
}

class TimerSettingsViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: TimerSettingsViewControllerDelegate?
    
    var pomodoroTime: Int = 25
    var shortBreakTime: Int = 5
    var longBreakTime: Int = 15
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var pomodoroSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 60
        slider.value = Float(pomodoroTime)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var shortBreakSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 30
        slider.value = Float(shortBreakTime)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var longBreakSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 60
        slider.value = Float(longBreakTime)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private let pomodoroLabel: UILabel = {
        let label = UILabel()
        label.text = "Pomodoro Duration: 25 min"
        return label
    }()
    
    private let shortBreakLabel: UILabel = {
        let label = UILabel()
        label.text = "Short Break Duration: 5 min"
        return label
    }()
    
    private let longBreakLabel: UILabel = {
        let label = UILabel()
        label.text = "Long Break Duration: 15 min"
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Timer Settings"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        
        view.addSubview(stackView)
        
        // Add Pomodoro settings
        let pomodoroStack = createSettingStack(
            label: pomodoroLabel,
            slider: pomodoroSlider
        )
        stackView.addArrangedSubview(pomodoroStack)
        
        // Add Short Break settings
        let shortBreakStack = createSettingStack(
            label: shortBreakLabel,
            slider: shortBreakSlider
        )
        stackView.addArrangedSubview(shortBreakStack)
        
        // Add Long Break settings
        let longBreakStack = createSettingStack(
            label: longBreakLabel,
            slider: longBreakSlider
        )
        stackView.addArrangedSubview(longBreakStack)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        updateLabels()
    }
    
    private func createSettingStack(label: UILabel, slider: UISlider) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(slider)
        return stack
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged(_ slider: UISlider) {
        if slider === pomodoroSlider {
            pomodoroTime = Int(slider.value)
        } else if slider === shortBreakSlider {
            shortBreakTime = Int(slider.value)
        } else if slider === longBreakSlider {
            longBreakTime = Int(slider.value)
        }
        updateLabels()
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didUpdateTimerSettings(
            pomodoro: pomodoroTime,
            shortBreak: shortBreakTime,
            longBreak: longBreakTime
        )
        dismiss(animated: true)
    }
    
    private func updateLabels() {
        pomodoroLabel.text = "Pomodoro Duration: \(pomodoroTime) min"
        shortBreakLabel.text = "Short Break Duration: \(shortBreakTime) min"
        longBreakLabel.text = "Long Break Duration: \(longBreakTime) min"
    }
} 