import Foundation

@MainActor
protocol CollectionItemCardViewEventsHandler {
    func toggleWishlistItem(id: String, isAdded: Bool)
    func openCollectionItemDetails(itemId: String)
}
