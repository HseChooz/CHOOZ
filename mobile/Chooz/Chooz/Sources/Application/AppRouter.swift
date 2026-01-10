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
    
    // MARK: - Internal Methods
    
    func setRoot(_ viewController: UIViewController, animated: Bool = false) {
        navigationController.setViewControllers([viewController], animated: animated)
    }
    
    func push(_ viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }
        
    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }
        
    func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }
    
    // MARK: - Private Properties
    
    private let window: UIWindow
    private let navigationController: UINavigationController
}
