import Foundation

@MainActor
protocol CollectionsListLoadedViewEventsHandler:
    CollectionsListCollectionCardViewEventsHandler
{
    func refreshCollectionsList()
}
