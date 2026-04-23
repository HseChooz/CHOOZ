import UIKit

@MainActor
protocol AppTabBarControllerDeps {
    var appRouter: AppRouter { get }
    var calendarViewController: UIViewController { get }
    var mainTabViewController: UIViewController { get }
}

enum AppTab: Int {
    case main = 0
    case calendar = 1
}

@MainActor
final class AppTabBarController: UITabBarController {
    
    // MARK: - Init
    
    init(deps: AppTabBarDeps) {
        self.deps = deps
        super.init(nibName: nil, bundle: nil)

        setupViewControllers()
        setupAppearance()
        registerWithAppRouter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods
    
    func selectTab(_ tab: AppTab, popToRoot: Bool = false) {
        guard let viewControllers,
              viewControllers.indices.contains(tab.rawValue)
        else {
            return
        }

        selectedIndex = tab.rawValue
        updateActiveNavigationController()

        if popToRoot,
           let navigationController = selectedViewController as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
    }
        
    // MARK: - Private Properties
    
    private let deps: AppTabBarDeps
    
    // MARK: - Private Methods
    
    private func setupViewControllers() {
        deps.mainTabViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImages.Icons.globe,
            selectedImage: UIImages.Icons.globe
        )
        deps.calendarViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImages.Icons.calendar,
            selectedImage: UIImages.Icons.calendar
        )
        
        viewControllers = [
            deps.mainTabViewController,
            deps.calendarViewController
        ]
        delegate = self
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColors.Blue.blue500
        tabBar.unselectedItemTintColor = UIColors.Neutral.grey400
    }
    
    private func registerWithAppRouter() {
        deps.appRouter.appTabBarController = self
        updateActiveNavigationController()
    }
    
    private func updateActiveNavigationController() {
        let selected = selectedViewController as? UINavigationController
        deps.appRouter.activeTabNavigationController = selected
    }

}

// MARK: - UITabBarControllerDelegate

extension AppTabBarController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let navController = viewController as? UINavigationController else {
            return true
        }
        
        guard viewController === tabBarController.selectedViewController else {
            return true
        }
        
        if navController.viewControllers.count > 1 {
            navController.popToRootViewController(animated: true)
            return false
        }
        
        return true
    }
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        updateActiveNavigationController()
    }
}
