import Foundation
import AppMetricaCore

final class SettingsAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackNotificationsToggled(enabled: Bool, source: String) {
        analyticsService.track(enabled ? .notificationsEnabled(source: source) : .notificationsDisabled(source: source))
        
        let profile = MutableUserProfile()
        profile.apply(ProfileAttribute.customBool("notifications_enabled").withValue(enabled))
        analyticsService.reportUserProfile(profile)
    }
    
    func trackLogout() {
        analyticsService.track(.logout)
        analyticsService.sendEventsBuffer()
    }
    
    func trackAccountDeleted() {
        analyticsService.track(.accountDeleted)
        analyticsService.sendEventsBuffer()
    }
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.settings)
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
