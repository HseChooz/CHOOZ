import Foundation

enum AnalyticsEvent {
    
    // MARK: - Authentication
    
    case authCompleted(provider: String)
    
    // MARK: - Onboarding
    
    case onboardingCompleted(skipped: Bool)
    
    // MARK: - Wishlist
    
    case wishlistItemAdded(title: String)
    case wishlistItemEdited(itemId: String)
    case wishlistItemDeleted(itemId: String)
    
    // MARK: - Calendar
    
    case calendarEventAdded(title: String)
    case calendarEventEdited(eventId: String)
    case calendarEventDeleted(eventId: String)
    
    // MARK: - Notifications
    
    case notificationsEnabled(source: String)
    case notificationsDisabled(source: String)
    case pushNotificationOpened(eventId: String?)
    case calendarNotificationToggled(enabled: Bool)
    
    // MARK: - Surveys
    
    case featureRated(feature: String, rating: Int)
    case npsSubmitted(score: Int)
    
    // MARK: - Account
    
    case logout
    case accountDeleted
    
    // MARK: - Lifecycle
    
    case firstLaunch
    case appSessionStarted
    
    // MARK: - Referral
    
    case profileShared(userId: String)
    
    // MARK: - Screen Views
    
    case screenViewed(Screen)
    
    // MARK: - Internal Properties
    
    var name: String {
        switch self {
        case .authCompleted:
            return "auth_completed"
        case .onboardingCompleted:
            return "onboarding_completed"
        case .wishlistItemAdded:
            return "wishlist_item_added"
        case .wishlistItemEdited:
            return "wishlist_item_edited"
        case .wishlistItemDeleted:
            return "wishlist_item_deleted"
        case .calendarEventAdded:
            return "calendar_event_added"
        case .calendarEventEdited:
            return "calendar_event_edited"
        case .calendarEventDeleted:
            return "calendar_event_deleted"
        case .notificationsEnabled:
            return "notifications_enabled"
        case .notificationsDisabled:
            return "notifications_disabled"
        case .pushNotificationOpened:
            return "push_notification_opened"
        case .calendarNotificationToggled:
            return "calendar_notification_toggled"
        case .featureRated:
            return "feature_rated"
        case .npsSubmitted:
            return "nps_submitted"
        case .logout:
            return "logout"
        case .accountDeleted:
            return "account_deleted"
        case .firstLaunch:
            return "first_launch"
        case .appSessionStarted:
            return "app_session_started"
        case .profileShared:
            return "profile_shared"
        case .screenViewed:
            return "screen_viewed"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .authCompleted(let provider):
            return ["provider": provider]
        case .onboardingCompleted(let skipped):
            return ["skipped": String(skipped)]
        case .wishlistItemAdded(let title):
            return ["item_title": title]
        case .wishlistItemEdited(let itemId):
            return ["item_id": itemId]
        case .wishlistItemDeleted(let itemId):
            return ["item_id": itemId]
        case .calendarEventAdded(let title):
            return ["event_title": title]
        case .calendarEventEdited(let eventId):
            return ["event_id": eventId]
        case .calendarEventDeleted(let eventId):
            return ["event_id": eventId]
        case .notificationsEnabled(let source):
            return ["source": source]
        case .notificationsDisabled(let source):
            return ["source": source]
        case .pushNotificationOpened(let eventId):
            var params: [String: String] = [:]
            if let eventId {
                params["event_id"] = eventId
            }
            return params.isEmpty ? nil : params
        case .calendarNotificationToggled(let enabled):
            return ["enabled": String(enabled)]
        case .featureRated(let feature, let rating):
            return ["feature": feature, "rating": String(rating)]
        case .npsSubmitted(let score):
            return ["score": String(score)]
        case .logout:
            return ["timestamp": ISO8601DateFormatter().string(from: Date())]
        case .accountDeleted:
            return ["timestamp": ISO8601DateFormatter().string(from: Date())]
        case .profileShared(let userId):
            return ["user_id": userId]
        case .screenViewed(let screen):
            return ["screen": screen.rawValue]
        case .firstLaunch, .appSessionStarted:
            return nil
        }
    }
}
