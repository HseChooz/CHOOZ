import UIKit

enum ProfileNavigationDestination {
    case settings
}

@MainActor
protocol ProfileRouting: AnyObject {
    func routeTo(destination: ProfileNavigationDestination)
    func presentShareSheet(items: [Any])
}

@MainActor
final class ProfileRouter: ProfileRouting {
    
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
    
    func presentShareSheet(items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        appRouter.present(activityVC)
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let settingsFactory: SettingsFactory
}
