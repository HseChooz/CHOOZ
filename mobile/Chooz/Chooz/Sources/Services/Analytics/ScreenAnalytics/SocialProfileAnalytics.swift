import Foundation

final class SocialProfileAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.socialProfile)
    }
    
    func trackProfileOpened(source: String) {
        analyticsService.track(.profileOpened(source: source))
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
    
}
