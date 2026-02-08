import Foundation

@MainActor
final class AuthorizationRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, mainTabBarFactory: MainTabBarFactory) {
        self.appRouter = appRouter
        self.mainTabBarFactory = mainTabBarFactory
    }
    
    // MARK: - Internal Methods
    
    func routeToMainScreen() {
        let vc = mainTabBarFactory.makeScreen()
        appRouter.setRoot(vc, animated: true)
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let mainTabBarFactory: MainTabBarFactory
}
