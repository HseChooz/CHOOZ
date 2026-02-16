import Foundation

enum CalendarNavigationDestination {
    case profile
}

@MainActor
final class CalendarRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter, profileFactory: ProfileFactory) {
        self.appRouter = appRouter
        self.profileFactory = profileFactory
    }
    
    // MARK: - Internal Methods
    
    func routeTo(destination: CalendarNavigationDestination) {
        switch destination {
        case .profile:
            let vc = profileFactory.makeScreen()
            appRouter.setTabSelected(false)
            appRouter.push(vc, hideBackButton: true)
        }
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let profileFactory: ProfileFactory
}
