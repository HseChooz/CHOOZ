import UIKit

enum ProfileNavigationDestination {
    case settings
}

@MainActor
final class ProfileRouter {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        settingsFactory: SettingsFactory
    ) {
        self.appRouter = appRouter
        self.settingsFactory = settingsFactory
    }
    
    // MARK: - Internal Methods
    
    func routeTo(destination: ProfileNavigationDestination) {
        switch destination {
        case .settings:
            let vc = settingsFactory.makeScreen()
            appRouter.push(vc)
        }
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let settingsFactory: SettingsFactory
}
