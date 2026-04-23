import Foundation

@MainActor
protocol CollectionsListFactoryDeps:
    CollectionsListInteractorDeps,
    CollectionsListRouterDeps
{
    
}

@MainActor
struct CollectionsListFactoryDepsImpl: CollectionsListFactoryDeps {
    let collectionsListService: CollectionsListService
}
