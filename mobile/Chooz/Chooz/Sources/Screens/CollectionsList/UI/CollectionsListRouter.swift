import Foundation

@MainActor
protocol CollectionsListRouterDeps {
    var appRouter: AppRouter { get }
    var collectionFactory: CollectionFactory { get }
}

enum CollectionsListDestination {
    case collection(slug: String)
}

@MainActor
final class CollectionsListRouter {
    
    // MARK: - Init
    
    init(deps: CollectionsListRouterDeps) {
        self.deps = deps
    }
    
    func routeTo(destination: CollectionsListDestination) {
        switch destination {
        case .collection(let slug):
            let vc = deps.collectionFactory.makeScreen(with: slug)
            deps.appRouter.push(vc)
        }
    }
    
    // MARK: - Private Properties

    private let deps: CollectionsListRouterDeps
    
}
