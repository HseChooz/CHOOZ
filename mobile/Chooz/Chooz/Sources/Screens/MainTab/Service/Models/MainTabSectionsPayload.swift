import Foundation

struct MainTabSectionsPayload: Hashable {
    
    struct Section: Hashable {
        let key: String
        let title: String
        let collections: [Collection]
    }
    
    struct Collection: Hashable {
        let id: String
        let slug: String
        let title: String
        let subtitle: String
        let badge: String?
        let coverImageUrl: URL?
        let itemsCount: Int
    }
    
    let upcomingEvent: EventItem?
    let sections: [Section]
    
}
