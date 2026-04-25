import Foundation

@MainActor
protocol CollectionsListFactoryDeps:
    CollectionsListInteractorDeps,
    CollectionsListRouterDeps
{
    
}

@MainActor
struct CollectionsListFactoryDepsImpl: CollectionsListFactoryDeps {
    let appRouter: AppRouter
    let collectionFactory: CollectionFactory
    let collectionsListService: CollectionsListService
}
