import SwiftUI
import Observation

@MainActor
@Observable
final class CalendarViewModel:
    CalendarEmptyViewEventsHandler,
    CalendarErrorViewEventsHandler,
    EventViewEventsHandler
{
    
    // MARK: - Internal Properties
    
    private(set) var viewState: CalendarViewState = .empty
    var selectedEvent: EventItem?
    var isEventFormPresented: Bool = false
    private(set) var pendingEditEvent: EventItem?
    
    var eventFormType: EventFormType {
        pendingEditEvent.map { .edit($0) } ?? .add
    }
    
    var events: [EventItem] {
        if case .loaded(let events) = viewState {
            return events
        }
        return []
    }
    
    // MARK: - Init
    
    init(
        router: CalendarRouter,
        interactor: CalendarInteractor,
        toastManager: ToastManager
    ) {
        self.router = router
        self.interactor = interactor
        self.toastManager = toastManager
    }
    
    // MARK: - Internal Methods
    
    func getEvents() {
        getEventsTask?.cancel()
        
        getEventsTask = Task {
            viewState = .loading
            
            do {
                let events = try await interactor.getEvents()
                viewState = events.isEmpty ? .empty : .loaded(events)
            } catch {
                if !Task.isCancelled {
                    viewState = .error
                }
            }
        }
    }
    
    @discardableResult
    func saveEvent(
        title: String,
        description: String?,
        date: Date,
        link: String?
    ) -> Bool {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfEventDate = calendar.startOfDay(for: date)
        
        if startOfEventDate < startOfToday {
            toastManager.showError("Некорректная дата", subtitle: "Дата события не может быть в прошлом")
            return false
        }
        
        let isEditing = pendingEditEvent != nil
        
        saveEventTask?.cancel()
        saveEventTask = Task {
            do {
                if let editEvent = pendingEditEvent {
                    let updatedItem = try await interactor.updateEvent(
                        id: editEvent.id,
                        title: title,
                        date: date,
                        description: description ?? ""
                    )
                    mutateEvents { items in
                        if let idx = items.firstIndex(where: { $0.id == updatedItem.id }) {
                            items[idx] = updatedItem
                        }
                    }
                } else {
                    let newItem = try await interactor.createEvent(
                        title: title,
                        date: date,
                        description: description ?? ""
                    )
                    mutateEvents { $0.append(newItem) }
                    toastManager.showSuccessBlue("Добавлено новое событие")
                }
            } catch {
                if !Task.isCancelled {
                    if isEditing {
                        toastManager.showError("Не удалось сохранить изменения")
                    } else {
                        toastManager.showError("Не удалось создать событие")
                    }
                }
            }
        }
        
        return true
    }
    
    func clearPendingEdit() {
        pendingEditEvent = nil
    }
    
    func openProfile() {
        router.routeTo(destination: .profile)
    }
    
    // MARK: - EventViewEventsHandler
    
    func deleteEvent(id: String) {
        deleteEventTask?.cancel()
        
        deleteEventTask = Task {
            do {
                try await interactor.deleteEvent(id: id)
                selectedEvent = nil
                mutateEvents { $0.removeAll { $0.id == id } }
            } catch {
                if !Task.isCancelled {
                    toastManager.showError("Не удалось удалить событие")
                }
            }
        }
    }
    
    func editEvent(_ event: EventItem) {
        pendingEditEvent = event
        selectedEvent = nil
    }
    
    // MARK: - Private Properties
    
    private let router: CalendarRouter
    private let interactor: CalendarInteractor
    private let toastManager: ToastManager
    
    private var getEventsTask: Task<Void, Never>?
    private var saveEventTask: Task<Void, Never>?
    private var deleteEventTask: Task<Void, Never>?
    
    // MARK: - Private Methods
    
    private func mutateEvents(_ transform: (inout [EventItem]) -> Void) {
        var current = events
        transform(&current)
        current.sort { $0.date < $1.date }
        withAnimation(.easeInOut(duration: 0.3)) {
            viewState = current.isEmpty ? .empty : .loaded(current)
        }
    }
}
