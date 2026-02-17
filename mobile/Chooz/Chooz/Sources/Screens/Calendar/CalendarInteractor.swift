import Foundation

final class CalendarInteractor {
    
    // MARK: - Init
    
    init(calendarService: CalendarService) {
        self.calendarService = calendarService
    }
    
    // MARK: - Internal Methods
    
    func getEvents() async throws -> [EventItem] {
        try await calendarService.fetchEvents()
    }
    
    func createEvent(title: String, date: Date, description: String) async throws -> EventItem {
        try await calendarService.createEvent(title: title, date: date, description: description)
    }
    
    func updateEvent(id: String, title: String, date: Date, description: String) async throws -> EventItem {
        try await calendarService.updateEvent(id: id, title: title, date: date, description: description)
    }
    
    func deleteEvent(id: String) async throws {
        try await calendarService.deleteEvent(id: id)
    }
    
    // MARK: - Private Properties
    
    private let calendarService: CalendarService
}
