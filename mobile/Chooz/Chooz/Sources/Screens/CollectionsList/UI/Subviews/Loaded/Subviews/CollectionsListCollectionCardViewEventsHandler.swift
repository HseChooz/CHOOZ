import Foundation

@MainActor
protocol CollectionsListCollectionCardViewEventsHandler {
    func openCollection(with collectionSlug: String)
}
