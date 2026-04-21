import Foundation

@MainActor
protocol MainTabLoadedViewEventsHandler:
    MainTabDefaultSectionViewEventsHandler,
    MainTabUpcomingEventsSectionViewEventsHandler
{
    func refreshSections()
}
