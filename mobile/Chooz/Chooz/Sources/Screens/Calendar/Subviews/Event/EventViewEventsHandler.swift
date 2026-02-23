import SwiftUI

@MainActor
protocol EventViewEventsHandler {
    func deleteEvent(id: String)
    func editEvent(_ event: EventItem)
    func toggleNotification(for eventId: String, enabled: Bool)
    func toggleRepeatYearly(for eventId: String, enabled: Bool)
}
