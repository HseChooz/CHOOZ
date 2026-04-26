import Foundation

@MainActor
protocol CollectionItemDetailsFactoryDeps:
    CollectionItemDetailsInteractorDeps
{
    var analyticsService: AnalyticsService { get }
}

@MainActor
struct CollectionItemDetailsFactoryDepsImpl: CollectionItemDetailsFactoryDeps {
    let collectionItemDetailsService: CollectionItemDetailsService
    let analyticsService: AnalyticsService
}
