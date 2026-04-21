import UIKit

@MainActor
final class AppTabBarFactory {
    
    // MARK: - Init
    
    init(appTabBarDeps: AppTabBarDeps) {
        self.appTabBarDeps = appTabBarDeps
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        AppTabBarController(deps: appTabBarDeps)
    }
    
    // MARK: - Private Properties
    
    private let appTabBarDeps: AppTabBarDeps
}
