import Foundation
import Apollo

final class CalendarService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    // MARK: - Internal Methods
    
    func fetchEvents() async throws -> [EventItem] {
        let result: Result<[EventItem], Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.EventsQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { [dateFormatter] result in
                switch result {
                case .success(let graphQLResult):
                    let rawEvents = graphQLResult.data?.events ?? []
                    let items = rawEvents.compactMap { event -> EventItem? in
                        guard let date = dateFormatter.date(from: event.date) else {
                            return nil
                        }
                        return EventItem(
                            id: event.id,
                            title: event.title,
                            description: event.description,
                            link: nil,
                            date: date
                        )
                    }
                    continuation.resume(returning: .success(items))
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
    
    func createEvent(title: String, date: Date, description: String) async throws -> EventItem {
        let dateString = dateFormatter.string(from: date)
        
        let result: Result<EventItem, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.CreateEventMutation(
                    title: title,
                    date: dateString,
                    description: description
                )
            ) { [dateFormatter] result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.createEvent,
                       let parsedDate = dateFormatter.date(from: data.date) {
                        let item = EventItem(
                            id: data.id,
                            title: data.title,
                            description: data.description,
                            link: nil,
                            date: parsedDate
                        )
                        continuation.resume(returning: .success(item))
                    } else {
                        let error = NSError(
                            domain: "CalendarService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось создать событие"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
    
    func updateEvent(id: String, title: String, date: Date, description: String) async throws -> EventItem {
        let dateString = dateFormatter.string(from: date)
        
        let result: Result<EventItem, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.UpdateEventMutation(
                    id: id,
                    title: .some(title),
                    description: .some(description),
                    date: .some(dateString)
                )
            ) { [dateFormatter] result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.updateEvent,
                       let parsedDate = dateFormatter.date(from: data.date) {
                        let item = EventItem(
                            id: data.id,
                            title: data.title,
                            description: data.description,
                            link: nil,
                            date: parsedDate
                        )
                        continuation.resume(returning: .success(item))
                    } else {
                        let error = NSError(
                            domain: "CalendarService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось обновить событие"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        return try result.get()
    }
    
    func deleteEvent(id: String) async throws {
        let result: Result<Bool, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.DeleteEventMutation(id: id)
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let success = graphQLResult.data?.deleteEvent, success {
                        continuation.resume(returning: .success(true))
                    } else {
                        let error = NSError(
                            domain: "CalendarService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось удалить событие"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        let _ = try result.get()
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
