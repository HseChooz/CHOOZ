import Foundation

final class WishlistAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackWishAdded(title: String) {
        analyticsService.track(.wishlistItemAdded(title: title))
    }
    
    func trackWishEdited(itemId: String) {
        analyticsService.track(.wishlistItemEdited(itemId: itemId))
    }
    
    func trackWishDeleted(itemId: String) {
        analyticsService.track(.wishlistItemDeleted(itemId: itemId))
    }
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.wishlist)
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
