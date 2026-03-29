import Foundation

final class OnboardingAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackOnboardingCompleted(skipped: Bool) {
        analyticsService.track(.onboardingCompleted(skipped: skipped))
    }
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.onboarding)
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
