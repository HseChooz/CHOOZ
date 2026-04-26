import Foundation

final class CollectionsListAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.collectionsList)
    }
    
    func trackCollectionOpened(collectionSlug: String) {
        analyticsService.track(.collectionOpened(
            collectionSlug: collectionSlug,
            source: Screen.collectionsList.rawValue
        ))
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
