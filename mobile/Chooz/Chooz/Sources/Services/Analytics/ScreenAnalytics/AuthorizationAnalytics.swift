import Foundation

@MainActor
protocol AuthorizationAnalyticsDeps {
    var analyticsService: AnalyticsService { get }
}

@MainActor
final class AuthorizationAnalytics {
    
    // MARK: - Init
    
    init(deps: AuthorizationAnalyticsDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func trackAuthCompleted(provider: String) {
        deps.analyticsService.track(.authCompleted(provider: provider))
        deps.analyticsService.sendEventsBuffer()
    }
    
    func trackScreenViewed() {
        deps.analyticsService.trackScreen(.authorization)
    }
    
    func setUserProfileID(_ profileID: String) {
        deps.analyticsService.setUserProfileID(profileID)
    }
    
    // MARK: - Private Properties
    
    private let deps: AuthorizationAnalyticsDeps
    
}
