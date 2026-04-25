import Foundation

@MainActor
protocol CollectionLoadedViewEventsHandler:
    CollectionFilterViewEventsHandler,
    CollectionItemCardViewEventsHandler
{
    func refreshCollection()
}
