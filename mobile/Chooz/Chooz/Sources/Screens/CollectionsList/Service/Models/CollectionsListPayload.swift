import Foundation

struct CollectionsListPayload: Hashable {
    
    struct Collection: Hashable {
        let id: String
        let slug: String
        let title: String
        let subtitle: String
        let badge: String?
        let coverImageUrl: URL?
        let itemsCount: Int
    }
    
    let sectionId: String
    let title: String
    let collections: [Collection]
    
}
