import Foundation

struct CollectionItemDetailsPayload: Equatable {
    let id: String
    let wishItemId: String?
    let title: String
    let description: String
    let link: URL?
    let price: String?
    let currency: WishCurrency?
    let imageUrl: URL?
    var isAdded: Bool
}
