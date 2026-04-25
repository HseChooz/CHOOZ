import Foundation

@MainActor
protocol CollectionFilterViewEventsHandler {
    func toggleFilter(tag: String)
}
