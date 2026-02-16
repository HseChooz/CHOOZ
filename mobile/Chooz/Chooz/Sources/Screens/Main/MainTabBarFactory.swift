import UIKit

@MainActor
final class MainTabBarFactory {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, calendarFactory: CalendarFactory) {
        self.appRouter = appRouter
        self.calendarFactory = calendarFactory
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let calendarVC = calendarFactory.makeScreen()
        return MainTabBarController(appRouter: appRouter, calendarViewController: calendarVC)
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let calendarFactory: CalendarFactory
}
