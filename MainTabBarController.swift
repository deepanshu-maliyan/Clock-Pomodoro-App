import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let clockVC = ClockViewController()
        clockVC.tabBarItem = UITabBarItem(title: "Clock", image: UIImage(systemName: "clock"), tag: 0)
        
        let calendarVC = CalendarViewController()
        calendarVC.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 1)
        
        let pomodoroVC = PomodoroViewController()
        pomodoroVC.tabBarItem = UITabBarItem(title: "Pomodoro", image: UIImage(systemName: "timer"), tag: 2)
        
        let timerVC = TimerViewController()
        timerVC.tabBarItem = UITabBarItem(title: "Timer", image: UIImage(systemName: "timer.circle"), tag: 3)
        
        let stopwatchVC = StopwatchViewController()
        stopwatchVC.tabBarItem = UITabBarItem(title: "Stopwatch", image: UIImage(systemName: "stopwatch"), tag: 4)
        
        viewControllers = [clockVC, calendarVC, pomodoroVC, timerVC, stopwatchVC].map {
            UINavigationController(rootViewController: $0)
        }
    }
} 