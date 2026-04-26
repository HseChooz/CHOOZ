import Foundation

@MainActor
protocol CollectionFactoryDeps:
    CollectionInteractorDeps,
    CollectionRouterDeps,
    CollectionWishlistActionPerformerProducerDeps
{
    var analyticsService: AnalyticsService { get }
}

@MainActor
struct CollectionFactoryDepsImpl: CollectionFactoryDeps {
    let collectionService: CollectionService
    let collectionWishlistService: CollectionWishlistService
    let toastManager: ToastManager
    let appRouter: AppRouter
    let collectionItemDetailsFactory: CollectionItemDetailsFactory
    let analyticsService: AnalyticsService
}
