import Foundation

@MainActor
final class AppBootstraper {
    
    // MARK: - Init
    
    init(appContainer: AppContainer) {
        self.appContainer = appContainer
    }
    
    // MARK: - Internal Methods
    
    func start() {
        if !appContainer.userDefaultsService.hasSeenOnboarding {
            let vc = appContainer.onboardingFactory.makeScreen()
            appContainer.appRouter.setRoot(vc)
        } else {
            let vc = appContainer.authorizationFactory.makeScreen()
            appContainer.appRouter.setRoot(vc)
        }
    }
    
    // MARK: - Private Properties
    
    private let appContainer: AppContainer
}
