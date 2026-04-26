import Foundation

final class CollectionItemDetailsAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.collectionItemDetails)
    }
    
    func trackWishlistToggled(collectionSlug: String, itemId: String, enabled: Bool) {
        analyticsService.track(.collectionItemWishlistToggled(
            collectionSlug: collectionSlug,
            itemId: itemId,
            enabled: enabled,
            source: Screen.collectionItemDetails.rawValue
        ))
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
