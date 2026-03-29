import Foundation

final class AuthorizationAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackAuthCompleted(provider: String) {
        analyticsService.track(.authCompleted(provider: provider))
        analyticsService.sendEventsBuffer()
    }
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.authorization)
    }
    
    func setUserProfileID(_ profileID: String) {
        analyticsService.setUserProfileID(profileID)
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
