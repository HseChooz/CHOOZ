import Foundation

final class ProfileAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.profile)
    }
    
    func trackProfileShared(userId: String) {
        analyticsService.track(.profileShared(userId: userId))
    }
    
    func setUserProfileID(_ profileID: String) {
        analyticsService.setUserProfileID(profileID)
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
