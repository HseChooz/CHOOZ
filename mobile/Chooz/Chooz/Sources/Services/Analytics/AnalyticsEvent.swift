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
    
    // MARK: - Notes
    
    case noteCreated(title: String)
    case noteEdited(noteId: String)
    case noteDeleted(noteId: String)
    case noteFavoriteToggled(noteId: String, enabled: Bool)
    case noteLinkOpened(noteId: String)
    case noteDetailsOpened(noteId: String, source: String)
    case noteFormOpened(mode: String, source: String)
    
    // MARK: - Main Tab
    
    case mainTabCollectionOpened(collectionSlug: String)
    case mainTabCollectionsListOpened(sectionId: String)
    case mainTabUpcomingEventsOpened
    
    // MARK: - Collections
    
    case collectionOpened(collectionSlug: String, source: String)
    case collectionFilterToggled(collectionSlug: String, tag: String, enabled: Bool)
    case collectionItemOpened(collectionSlug: String, itemId: String)
    case collectionItemWishlistToggled(collectionSlug: String, itemId: String, enabled: Bool, source: String)
    
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
    case profileOpened(source: String)
    
    // MARK: - AI Insights
    
    case aiInsightsOpened(source: String)
    case aiInsightsGenerated
    case aiInsightsRegenerated
    case aiInsightsError
    
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
        case .noteCreated:
            return "note_created"
        case .noteEdited:
            return "note_edited"
        case .noteDeleted:
            return "note_deleted"
        case .noteFavoriteToggled:
            return "note_favorite_toggled"
        case .noteLinkOpened:
            return "note_link_opened"
        case .noteDetailsOpened:
            return "note_details_opened"
        case .noteFormOpened:
            return "note_form_opened"
        case .mainTabCollectionOpened:
            return "main_tab_collection_opened"
        case .mainTabCollectionsListOpened:
            return "main_tab_collections_list_opened"
        case .mainTabUpcomingEventsOpened:
            return "main_tab_upcoming_events_opened"
        case .collectionOpened:
            return "collection_opened"
        case .collectionFilterToggled:
            return "collection_filter_toggled"
        case .collectionItemOpened:
            return "collection_item_opened"
        case .collectionItemWishlistToggled:
            return "collection_item_wishlist_toggled"
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
        case .profileOpened:
            return "profile_opened"
        case .aiInsightsOpened:
            return "ai_insights_opened"
        case .aiInsightsGenerated:
            return "ai_insights_generated"
        case .aiInsightsRegenerated:
            return "ai_insights_regenerated"
        case .aiInsightsError:
            return "ai_insights_error"
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
        case .noteCreated(let title):
            return ["note_title": title]
        case .noteEdited(let noteId):
            return ["note_id": noteId]
        case .noteDeleted(let noteId):
            return ["note_id": noteId]
        case .noteFavoriteToggled(let noteId, let enabled):
            return ["note_id": noteId, "enabled": String(enabled)]
        case .noteLinkOpened(let noteId):
            return ["note_id": noteId]
        case .noteDetailsOpened(let noteId, let source):
            return ["note_id": noteId, "source": source]
        case .noteFormOpened(let mode, let source):
            return ["mode": mode, "source": source]
        case .mainTabCollectionOpened(let collectionSlug):
            return ["collection_slug": collectionSlug]
        case .mainTabCollectionsListOpened(let sectionId):
            return ["section_id": sectionId]
        case .mainTabUpcomingEventsOpened:
            return nil
        case .collectionOpened(let collectionSlug, let source):
            return ["collection_slug": collectionSlug, "source": source]
        case .collectionFilterToggled(let collectionSlug, let tag, let enabled):
            return ["collection_slug": collectionSlug, "tag": tag, "enabled": String(enabled)]
        case .collectionItemOpened(let collectionSlug, let itemId):
            return ["collection_slug": collectionSlug, "item_id": itemId]
        case .collectionItemWishlistToggled(let collectionSlug, let itemId, let enabled, let source):
            return [
                "collection_slug": collectionSlug,
                "item_id": itemId,
                "enabled": String(enabled),
                "source": source
            ]
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
        case .profileOpened(let source):
            return ["source": source]
        case .screenViewed(let screen):
            return ["screen": screen.rawValue]
        case .aiInsightsOpened(let source):
            return ["source": source]
        case .aiInsightsGenerated, .aiInsightsRegenerated, .aiInsightsError:
            return nil
        case .firstLaunch, .appSessionStarted:
            return nil
        }
    }
}
