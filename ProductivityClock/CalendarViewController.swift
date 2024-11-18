import UIKit

class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private let calendarView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        return collectionView
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var days: [String] = []
    private var currentDate = Date()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        setupUI()
        setupCalendar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(calendarView)
        calendarView.addSubview(monthLabel)
        calendarView.addSubview(previousButton)
        calendarView.addSubview(nextButton)
        calendarView.addSubview(calendarCollectionView)
        
        previousButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendarView.heightAnchor.constraint(equalToConstant: 400),
            
            monthLabel.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 16),
            monthLabel.centerXAnchor.constraint(equalTo: calendarView.centerXAnchor),
            
            previousButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            
            calendarCollectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 20),
            calendarCollectionView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
            calendarCollectionView.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor)
        ])
    }
    
    private func setupCalendar() {
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        updateCalendarData()
    }
    
    // MARK: - Calendar Methods
    private func updateCalendarData() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: currentDate)
        
        days = calculateDaysInMonth()
        calendarCollectionView.reloadData()
    }
    
    private func calculateDaysInMonth() -> [String] {
        var days: [String] = []
        let calendar = Calendar.current
        
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Add empty spaces for days before the first day of month
        for _ in 1..<firstWeekday {
            days.append("")
        }
        
        // Add all days in month
        for day in 1...range.count {
            days.append("\(day)")
        }
        
        return days
    }
    
    // MARK: - Actions
    @objc private func previousMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }
        currentDate = newDate
        updateCalendarData()
    }
    
    @objc private func nextMonth() {
        guard let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else { return }
        currentDate = newDate
        updateCalendarData()
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count + 7 // Add 7 for weekday labels
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        if indexPath.item < 7 {
            cell.configure(with: daysOfWeek[indexPath.item], isHeader: true)
        } else {
            cell.configure(with: days[indexPath.item - 7], isHeader: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 50)
    }
} 