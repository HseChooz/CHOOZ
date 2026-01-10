import Foundation

@MainActor
final class OnboardingRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, authorizationFactory: AuthorizationFactory) {
        self.appRouter = appRouter
        self.authorizationFactory = authorizationFactory
    }
    
    // MARK: - Internal Methods
    
    func routeToAuthorizationScreen() {
        let vc = authorizationFactory.makeScreen()
        appRouter.push(vc)
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let authorizationFactory: AuthorizationFactory
}
