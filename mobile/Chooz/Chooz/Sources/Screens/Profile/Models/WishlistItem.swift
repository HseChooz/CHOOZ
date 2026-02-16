import Foundation

struct WishlistItem: Identifiable {
    let id: String
    let title: String
    let description: String?
    let link: String?
    let price: String?
    let currency: WishCurrency?
}
