import Foundation

struct WishlistItem: Identifiable {
    let id: String
    let title: String
    let description: String?
    let link: String?
    let price: String?
    let currency: WishCurrency?
    let imageUrl: String?
    let isFromCollection: Bool

    var isEditable: Bool {
        !isFromCollection
    }

    init(
        id: String,
        title: String,
        description: String?,
        link: String?,
        price: String?,
        currency: WishCurrency?,
        imageUrl: String?,
        isFromCollection: Bool = true
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.link = link
        self.price = price
        self.currency = currency
        self.imageUrl = imageUrl
        self.isFromCollection = isFromCollection
    }
}
