import UIKit

class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let calendar = Calendar.current
    private var selectedDate = Date()
    private var totalSquares = [String]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setCellsView()
        setMonthView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Calendar"
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    private func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        let firstDayOfMonth = calendar.component(.weekday, from: selectedDate)
        let startingSpaces = firstDayOfMonth - 1
        
        var count: Int = 1
        
        while count <= 42 {
            if count <= startingSpaces || count - startingSpaces > daysInMonth {
                totalSquares.append("")
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        let dayString = totalSquares[indexPath.item]
        if let dayInt = Int(dayString) {
            cell.configure(with: dayInt)
        } else {
            cell.configure(with: 0)
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
} 