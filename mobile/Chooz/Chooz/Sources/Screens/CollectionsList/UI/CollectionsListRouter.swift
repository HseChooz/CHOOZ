import Foundation

@MainActor
protocol CollectionsListRouterDeps {
    
}

enum CollectionsListDestination {
    case collection(id: String)
}

@MainActor
final class CollectionsListRouter {
    
    // MARK: - Init
    
    init(deps: CollectionsListRouterDeps) {
        self.deps = deps
    }
    
    func routeTo(destination: CollectionsListDestination) {
        switch destination {
        case .collection(let id): break
        }
    }
    
    // MARK: - Private Properties

    private let deps: CollectionsListRouterDeps
    
}
