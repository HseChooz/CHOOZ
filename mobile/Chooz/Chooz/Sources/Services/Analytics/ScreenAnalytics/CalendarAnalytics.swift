import Foundation

final class CalendarAnalytics {
    
    // MARK: - Init
    
    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func trackEventAdded(title: String) {
        analyticsService.track(.calendarEventAdded(title: title))
    }
    
    func trackEventEdited(eventId: String) {
        analyticsService.track(.calendarEventEdited(eventId: eventId))
    }
    
    func trackEventDeleted(eventId: String) {
        analyticsService.track(.calendarEventDeleted(eventId: eventId))
    }
    
    func trackNotificationToggled(enabled: Bool) {
        analyticsService.track(.calendarNotificationToggled(enabled: enabled))
    }
    
    func trackScreenViewed() {
        analyticsService.trackScreen(.calendar)
    }
    
    // MARK: - Private Properties
    
    private let analyticsService: AnalyticsService
}
