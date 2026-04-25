import Foundation

struct CollectionPayload: Hashable {
    
    struct Item: Hashable {
        let id: String
        let title: String
        let description: String
        let link: URL?
        let price: String?
        let currency: WishCurrency?
        let tags: [String]
        let imageUrl: URL?
        var isAdded: Bool
        var wishItemId: String?
    }
    
    let id: String
    let slug: String
    let title: String
    let subtitle: String
    let description: String
    let badge: String?
    let coverImageUrl: URL?
    let sectionKey: String
    let sectionTitle: String
    let tags: [String]
    let itemsCount: Int
    var items: [Item]
    
}
