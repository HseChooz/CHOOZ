import Foundation

@MainActor
protocol SettingsRouterDeps {
    var appRouter: AppRouter { get }
    var debugPanelFactory: DebugPanelFactory { get }
}

@MainActor
protocol SettingsRouting: AnyObject {
    func routeTo(destination: SettingsDestination)
}

enum SettingsDestination {
    case debugPanel
}

@MainActor
final class SettingsRouter: SettingsRouting, WishlistSharePresenting {
    
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

    func presentShareSheet(items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        deps.appRouter.present(activityVC)
    }
    
    // MARK: - Private Properties
    
    private let deps: SettingsRouterDeps
    
}
