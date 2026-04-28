import Foundation

@MainActor
protocol SettingsRouterDeps {
    var appRouter: AppRouter { get }
    var debugPanelFactory: DebugPanelFactory { get }
}

enum SettingsDestination {
    case debugPanel
}

@MainActor
final class SettingsRouter {
    
    // MARK: - Init
    
    init(deps: SettingsRouterDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func routeTo(destination: SettingsDestination) {
        switch destination {
        case .debugPanel:
            let vc = deps.debugPanelFactory.makeScreen()
            deps.appRouter.push(vc)
        }
    }
    
    // MARK: - Private Properties
    
    private let deps: SettingsRouterDeps
    
}
