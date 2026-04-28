import Foundation
import UIKit

@MainActor
protocol MainTabRouterDeps {
    var appRouter: AppRouter { get }
    var profileFactory: ProfileFactory { get }
    var collectionsListFactory: CollectionsListFactory { get }
    var collectionFactory: CollectionFactory { get }
}

enum MainTabDestination {
    case profile
    case calendar
    case collection(slug: String)
    case collectionsList(id: String)
}

@MainActor
final class MainTabRouter {
    
    // MARK: - Init
    
    init(deps: MainTabRouterDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func routeTo(destination: MainTabDestination) {
        switch destination {
        case .profile:
            let vc = deps.profileFactory.makeScreen()
            deps.appRouter.push(vc)
        case .calendar:
            deps.appRouter.selectTab(.calendar, popToRoot: true)
        case .collection(let slug):
            let vc = deps.collectionFactory.makeScreen(with: slug)
            deps.appRouter.push(vc)
        case .collectionsList(let id):
            let vc = deps.collectionsListFactory.makeScreen(with: id)
            deps.appRouter.push(vc)
        }
    }
    
    // MARK: - Private Methods
    
    private let deps: MainTabRouterDeps
    
}
