import Foundation

@MainActor
protocol ProfileAnalyticsTracking: AnyObject {
    func trackScreenViewed()
    func trackProfileShared(userId: String)
    func setUserProfileID(_ profileID: String)
}

@MainActor
final class ProfileAnalytics: ProfileAnalyticsTracking {
    
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
