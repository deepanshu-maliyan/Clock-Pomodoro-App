import UIKit

protocol EventFormViewControllerDelegate: AnyObject {
    func eventFormViewController(_ controller: EventFormViewController, didSaveEvent event: Event)
}

class EventFormViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        table.register(TextViewCell.self, forCellReuseIdentifier: "TextViewCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let titleTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let durationPicker = UIDatePicker()
    private let notesTextView = UITextView()
    
    private var event: Event?
    weak var delegate: EventFormViewControllerDelegate?
    
    // MARK: - Initialization
    init(event: Event? = nil) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        configureWithEvent()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = event == nil ? "New Event" : "Edit Event"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure pickers
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        
        durationPicker.datePickerMode = .countDownTimer
        durationPicker.preferredDatePickerStyle = .wheels
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    private func configureWithEvent() {
        guard let event = event else { return }
        
        titleTextField.text = event.title
        datePicker.date = event.date
        durationPicker.countDownDuration = event.duration
        notesTextView.text = event.notes
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Please enter a title for the event")
            return
        }
        
        let newEvent = Event(
            title: title,
            date: datePicker.date,
            duration: durationPicker.countDownDuration,
            notes: notesTextView.text
        )
        
        if var existingEvent = event {
            existingEvent.title = newEvent.title
            existingEvent.date = newEvent.date
            existingEvent.duration = newEvent.duration
            existingEvent.notes = newEvent.notes
            delegate?.eventFormViewController(self, didSaveEvent: existingEvent)
        } else {
            delegate?.eventFormViewController(self, didSaveEvent: newEvent)
        }
        
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension EventFormViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Title"
        case 1: return "Date"
        case 2: return "Duration"
        case 3: return "Notes"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            cell.configure(with: titleTextField, placeholder: "Event Title")
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.contentView.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                datePicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                datePicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                datePicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
            ])
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.contentView.addSubview(durationPicker)
            durationPicker.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                durationPicker.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                durationPicker.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                durationPicker.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                durationPicker.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
            ])
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell", for: indexPath) as! TextViewCell
            cell.configure(with: notesTextView, placeholder: "Add notes...")
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1, 2: return 216
        case 3: return 150
        default: return UITableView.automaticDimension
        }
    }
} 