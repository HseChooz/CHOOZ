import Foundation

@MainActor
protocol AuthorizationRouterDeps {
    var appRouter: AppRouter { get }
    var deepLinkService: DeepLinkService { get }
}

@MainActor
final class AuthorizationRouter {
    
    // MARK: - Init
    
    init(deps: AuthorizationRouterDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func routeToMainScreen() {
        guard let vc = deps.appRouter.screenFactory?.makeAppTabBarScreen() else {
            return
        }
        deps.appRouter.setRoot(vc, animated: true)
        deps.deepLinkService.consumePendingDeepLink()
    }
    
    // MARK: - Private Properties
    
    private let deps: AuthorizationRouterDeps
    
}
