import UIKit

@MainActor
final class AppRouter {
    
    // MARK: - Init
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    // MARK: - Internal Properties
    
    weak var activeTabNavigationController: UINavigationController?
    weak var mainTabBarController: MainTabBarController?
    
    var topViewController: UIViewController? {
        let nav = activeNavigationController
        return nav.topViewController ?? nav
    }
    
    // MARK: - Internal Methods
    
    func setRoot(_ viewController: UIViewController, animated: Bool = false) {
        navigationController.setViewControllers([viewController], animated: animated)
    }
    
    func push(_ viewController: UIViewController, animated: Bool = true, hideBackButton: Bool = false) {
        if hideBackButton {
            viewController.navigationItem.hidesBackButton = true
        }
        activeNavigationController.pushViewController(viewController, animated: animated)
    }
    
    func pop(animated: Bool = true) {
        _ = activeNavigationController.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        _ = activeNavigationController.popToRootViewController(animated: animated)
    }
    
    func setTabSelected(_ selected: Bool) {
        mainTabBarController?.setTabSelected(selected)
    }
    
    // MARK: - Private Properties
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    private var activeNavigationController: UINavigationController {
        activeTabNavigationController ?? navigationController
    }
}
