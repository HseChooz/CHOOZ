import Foundation

@MainActor
protocol MainTabBadgeViewEventsHandler {
    func openCollection(with slug: String)
}
