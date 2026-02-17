import SwiftUI

@MainActor
protocol EventViewEventsHandler {
    func deleteEvent(id: String)
    func editEvent(_ event: EventItem)
}
