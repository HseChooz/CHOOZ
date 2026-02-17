import Foundation

@MainActor
protocol CalendarEmptyViewEventsHandler {
    @discardableResult
    func saveEvent(title: String, description: String?, date: Date, link: String?) -> Bool
}
