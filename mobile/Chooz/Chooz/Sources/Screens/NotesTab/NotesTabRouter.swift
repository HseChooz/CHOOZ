import Foundation

@MainActor
protocol NotesTabRouterDeps {
    var appRouter: AppRouter { get }
    var profileFactory: ProfileFactory { get }
}

enum NotesTabDestination {
    case profile
}

@MainActor
final class NotesTabRouter {
    
    // MARK: - Init
    
    init(deps: NotesTabRouterDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func routeTo(destination: NotesTabDestination) {
        switch destination {
        case .profile:
            let vc = deps.profileFactory.makeScreen()
            deps.appRouter.push(vc)
        }
    }
    
    // MARK: - Private Methods
    
    private let deps: NotesTabRouterDeps
    
}
