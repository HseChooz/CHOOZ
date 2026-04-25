import Foundation

@MainActor
protocol CollectionRouterDeps {
    var appRouter: AppRouter { get }
    var collectionItemDetailsFactory: CollectionItemDetailsFactory { get }
}

enum CollectiontDestination {
    case collectionItemDetails(
        collectionSlug: String,
        itemId: String,
        wishlistPerformer: any CollectionWishlistActionPerformer,
        wishlistReporter: any CollectionWishlistActionReporter
    )
}

@MainActor
protocol CollectionRouter: AnyObject {
    func routeTo(destination: CollectiontDestination)
}

@MainActor
final class CollectionRouterImpl: CollectionRouter {
    
    // MARK: - Init
    
    init(deps: CollectionRouterDeps) {
        self.deps = deps
    }
    
    func routeTo(destination: CollectiontDestination) {
        switch destination {
        case .collectionItemDetails(let collectionSlug, let itemId, let wishlistPerformer, let wishlistReporter):
            let vc = deps.collectionItemDetailsFactory.makeScreen(
                with: collectionSlug,
                itemId: itemId,
                wishlistPerformer: wishlistPerformer,
                wishlistReporter: wishlistReporter
            )
            deps.appRouter.presentAdaptivePopup(vc)
        }
    }
    
    // MARK: - Private Properties

    private let deps: CollectionRouterDeps
    
}
