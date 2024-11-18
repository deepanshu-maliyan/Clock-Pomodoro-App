import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let calendarVC = CalendarViewController()
        calendarVC.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 0)
        
        viewControllers = [calendarVC].map {
            UINavigationController(rootViewController: $0)
        }
    }
} 