import UIKit

protocol CalendarViewDelegate: AnyObject {
    func calendarView(_ calendarView: CalendarView, didSelectDate date: Date)
}

class CalendarView: UIView {
    
    // MARK: - Properties
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let daysContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dayButtons: [UIButton] = []
    private let calendar = Calendar.current
    private var currentMonth = Date()
    weak var delegate: CalendarViewDelegate?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        updateCalendar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
        updateCalendar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Add navigation controls
        addSubview(monthLabel)
        addSubview(previousButton)
        addSubview(nextButton)
        
        // Add weekday labels
        addSubview(weekdayStackView)
        setupWeekdayLabels()
        
        // Add days container
        addSubview(daysContainerView)
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            previousButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 16),
            weekdayStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            weekdayStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            daysContainerView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 8),
            daysContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            daysContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            daysContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupWeekdayLabels() {
        let weekdaySymbols = calendar.veryShortWeekdaySymbols
        for symbol in weekdaySymbols {
            let label = UILabel()
            label.text = symbol
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .secondaryLabel
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    private func setupActions() {
        previousButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
    }
    
    private func updateCalendar() {
        // Update month label
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: currentMonth)
        
        // Remove existing day buttons
        dayButtons.forEach { $0.removeFromSuperview() }
        dayButtons.removeAll()
        
        // Calculate dates
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        // Create grid layout
        let buttonSize = daysContainerView.bounds.width / 7
        let offsetDays = firstWeekday - calendar.firstWeekday
        
        // Create day buttons
        for day in 1...daysInMonth {
            let button = createDayButton(day: day)
            let row = (day + offsetDays - 1) / 7
            let col = (day + offsetDays - 1) % 7
            
            button.frame = CGRect(
                x: CGFloat(col) * buttonSize,
                y: CGFloat(row) * buttonSize,
                width: buttonSize,
                height: buttonSize
            )
            
            daysContainerView.addSubview(button)
            dayButtons.append(button)
        }
        
        // Update button states
        updateButtonStates()
    }
    
    private func createDayButton(day: Int) -> UIButton {
        let button = UIButton()
        button.setTitle("\(day)", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func updateButtonStates() {
        let today = calendar.startOfDay(for: Date())
        
        for (index, button) in dayButtons.enumerated() {
            guard let buttonDate = getDate(forDayButton: button) else { continue }
            
            // Style for today
            if calendar.isDate(buttonDate, inSameDayAs: today) {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.label, for: .normal)
            }
            
            // Style for selected date
            if let selectedDate = selectedDate,
               calendar.isDate(buttonDate, inSameDayAs: selectedDate) {
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                button.layer.borderWidth = 0
            }
        }
    }
    
    private func getDate(forDayButton button: UIButton) -> Date? {
        guard let dayText = button.title(for: .normal),
              let day = Int(dayText) else { return nil }
        
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = day
        return calendar.date(from: components)
    }
    
    // MARK: - Actions
    @objc private func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        currentMonth = newDate
        updateCalendar()
    }
    
    @objc private func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = newDate
        updateCalendar()
    }
    
    @objc private func dayButtonTapped(_ sender: UIButton) {
        guard let date = getDate(forDayButton: sender) else { return }
        selectedDate = date
        updateButtonStates()
        delegate?.calendarView(self, didSelectDate: date)
    }
    
    // MARK: - Public Methods
    private var selectedDate: Date?
    
    func selectDate(_ date: Date) {
        selectedDate = date
        currentMonth = date
        updateCalendar()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCalendar()
    }
} 