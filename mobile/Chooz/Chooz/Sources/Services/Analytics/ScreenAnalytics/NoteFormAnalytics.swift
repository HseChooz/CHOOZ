import Foundation

final class NoteFormAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.noteForm)
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
