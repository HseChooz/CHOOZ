import Foundation

@MainActor
protocol CollectionsListFactoryDeps:
    CollectionsListInteractorDeps,
    CollectionsListRouterDeps
{
    var analyticsService: AnalyticsService { get }
}

@MainActor
struct CollectionsListFactoryDepsImpl: CollectionsListFactoryDeps {
    let appRouter: AppRouter
    let collectionFactory: CollectionFactory
    let collectionsListService: CollectionsListService
    let analyticsService: AnalyticsService
}
