import Foundation

@MainActor
protocol CollectionsListCollectionCardViewEventsHandler {
    func openCollection(with collectionId: String)
}
