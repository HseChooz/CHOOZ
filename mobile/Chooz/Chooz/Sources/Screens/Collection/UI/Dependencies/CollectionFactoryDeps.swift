import Foundation

@MainActor
protocol CollectionFactoryDeps:
    CollectionInteractorDeps,
    CollectionRouterDeps,
    CollectionWishlistActionPerformerProducerDeps
{}

@MainActor
struct CollectionFactoryDepsImpl: CollectionFactoryDeps {
    let collectionService: CollectionService
    let collectionWishlistService: CollectionWishlistService
    let toastManager: ToastManager
    let appRouter: AppRouter
    let collectionItemDetailsFactory: CollectionItemDetailsFactory
}
