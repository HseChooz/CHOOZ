import Foundation

@MainActor
final class SettingsRouter {
    
    // MARK: - Init
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - Internal Methods
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
}
