import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, calendarViewController: UIViewController) {
        self.appRouter = appRouter
        super.init(nibName: nil, bundle: nil)
        
        calendarViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImages.Icons.calendar,
            selectedImage: UIImages.Icons.calendar
        )
        
        viewControllers = [calendarViewController]
        delegate = self
        
        setupAppearance()
        registerWithAppRouter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Properties
    
    private(set) var isTabSelected = true
    
    // MARK: - Internal Methods
    
    func setTabSelected(_ selected: Bool) {
        isTabSelected = selected
        tabBar.tintColor = selected ? UIColor(named: "blue500") : UIColor(named: "grey400")
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    
    // MARK: - Private Methods
    
    private func registerWithAppRouter() {
        appRouter.mainTabBarController = self
        updateActiveNavigationController()
    }
    
    private func updateActiveNavigationController() {
        let selected = selectedViewController as? UINavigationController
        appRouter.activeTabNavigationController = selected
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor(named: "blue500")
        tabBar.unselectedItemTintColor = UIColor(named: "grey400")
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let navController = viewController as? UINavigationController else {
            return true
        }
        
        if navController.viewControllers.count > 1 {
            setTabSelected(true)
            navController.popToRootViewController(animated: true)
            return false
        }
        
        return true
    }
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        setTabSelected(true)
        updateActiveNavigationController()
    }
}
