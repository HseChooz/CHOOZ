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
            appRouter.push(vc)
        }
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let profileFactory: ProfileFactory
    
}
