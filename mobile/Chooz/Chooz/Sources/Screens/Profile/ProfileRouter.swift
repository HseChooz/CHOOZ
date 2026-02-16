import Foundation

enum ProfileNavigationDestination {
    // extensible for future: .settings, .editProfile, etc.
}

@MainActor
final class ProfileRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - Internal Methods
    
    func routeTo(destination: ProfileNavigationDestination) {}
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
}
