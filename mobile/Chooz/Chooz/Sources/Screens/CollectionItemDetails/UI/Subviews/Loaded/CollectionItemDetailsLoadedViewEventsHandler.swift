import Foundation

@MainActor
protocol CollectionItemDetailsLoadedViewEventsHandler {
    func addToWishlist(collectionItemId: String)
    func removeFromWishlist(collectionItemId: String)
}
