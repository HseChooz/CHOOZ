import Foundation

@MainActor
final class AppContainer {
    
    // MARK: - Init
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - Router
    
    let appRouter: AppRouter
    
    // MARK: - Services
    
    lazy var userDefaultsService: UserDefaultsService = UserDefaultsService()
    
    // MARK: - Factories
    
    lazy var authorizationFactory: AuthorizationFactory = AuthorizationFactory()
    lazy var onboardingFactory: OnboardingFactory = OnboardingFactory(
        appRouter: appRouter,
        userDefaultsService: userDefaultsService,
        authorizationFactory: authorizationFactory
    )
}
