import Foundation

final class CollectionAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.collection)
    }
    
    func trackFilterToggled(collectionSlug: String, tag: String, enabled: Bool) {
        analyticsService.track(.collectionFilterToggled(
            collectionSlug: collectionSlug,
            tag: tag,
            enabled: enabled
        ))
    }
    
    func trackItemOpened(collectionSlug: String, itemId: String) {
        analyticsService.track(.collectionItemOpened(
            collectionSlug: collectionSlug,
            itemId: itemId
        ))
    }
    
    func trackWishlistToggled(collectionSlug: String, itemId: String, enabled: Bool) {
        analyticsService.track(.collectionItemWishlistToggled(
            collectionSlug: collectionSlug,
            itemId: itemId,
            enabled: enabled,
            source: Screen.collection.rawValue
        ))
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
