import Foundation

@MainActor
protocol CalendarErrorViewEventsHandler {
    func getEvents(force: Bool)
}
