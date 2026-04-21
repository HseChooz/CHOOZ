import Foundation

@MainActor
protocol AuthorizationRouterDeps {
    var appRouter: AppRouter { get }
    var appTabBarFactory: AppTabBarFactory { get }
}

@MainActor
final class AuthorizationRouter {
    
    // MARK: - Init
    
    init(deps: AuthorizationRouterDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func routeToMainScreen() {
        let vc = deps.appTabBarFactory.makeScreen()
        deps.appRouter.setRoot(vc, animated: true)
    }
    
    // MARK: - Private Properties
    
    private let deps: AuthorizationRouterDeps
    
}
