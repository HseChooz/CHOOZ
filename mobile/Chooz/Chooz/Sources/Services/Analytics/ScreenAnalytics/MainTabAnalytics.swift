import Foundation

final class MainTabAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.mainTab)
    }
    
    func trackProfileOpened() {
        analyticsService.track(.profileOpened(source: Screen.mainTab.rawValue))
    }
    
    func trackCollectionOpened(collectionSlug: String) {
        analyticsService.track(.mainTabCollectionOpened(collectionSlug: collectionSlug))
    }
    
    func trackCollectionsListOpened(sectionId: String) {
        analyticsService.track(.mainTabCollectionsListOpened(sectionId: sectionId))
    }
    
    func trackUpcomingEventsOpened() {
        analyticsService.track(.mainTabUpcomingEventsOpened)
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
