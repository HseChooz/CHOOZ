import Foundation
import Apollo

@MainActor
struct MainTabFactoryDepsImpl: MainTabFactoryDeps {
    let appRouter: AppRouter
    let profileFactory: ProfileFactory
    let mainTabService: MainTabService
    let calendarFactory: CalendarFactory
    let collectionsListFactory: CollectionsListFactory
    let collectionFactory: CollectionFactory
    let analyticsService: AnalyticsService
}
