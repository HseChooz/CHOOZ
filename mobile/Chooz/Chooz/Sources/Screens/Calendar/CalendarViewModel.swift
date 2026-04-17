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
    private var isDataLoaded: Bool = false
    
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
        userDefaultsService: UserDefaultsService,
        notificationService: NotificationService,
        toastManager: ToastManager,
        analytics: CalendarAnalytics
    ) {
        self.router = router
        self.interactor = interactor
        self.userDefaultsService = userDefaultsService
        self.notificationService = notificationService
        self.toastManager = toastManager
        self.analytics = analytics
    }
    
    // MARK: - Internal Methods
    
    func onCalendarAppear() {
        getEvents()
        rescheduleNotificationsFromLoadedStateIfNeeded()
    }
    
    func getEvents(force: Bool = false) {
        guard force || !isDataLoaded else { return }
        
        getEventsTask?.cancel()
        
        getEventsTask = Task {
            viewState = .loading
            
            do {
                let events = try await interactor.getEvents()
                viewState = events.isEmpty ? .empty : .loaded(events)
                notificationService.rescheduleNotifications(for: events)
                isDataLoaded = true
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
                        description: description ?? "",
                        link: link ?? ""
                    )
                    mutateEvents { items in
                        if let idx = items.firstIndex(where: { $0.id == updatedItem.id }) {
                            items[idx] = updatedItem
                        }
                    }
                    notificationService.cancelNotification(for: updatedItem.id)
                    notificationService.scheduleNotification(for: updatedItem)
                    analytics.trackEventEdited(eventId: editEvent.id)
                } else {
                    let newItem = try await interactor.createEvent(
                        title: title,
                        date: date,
                        description: description ?? "",
                        link: link ?? "",
                        notifyEnabled: false,
                        repeatYearly: false
                    )
                    mutateEvents { $0.append(newItem) }
                    analytics.trackEventAdded(title: title)
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
                notificationService.cancelNotification(for: id)
                analytics.trackEventDeleted(eventId: id)
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
    
    func toggleNotification(for eventId: String, enabled: Bool) {
        toggleNotificationTask?.cancel()
        toggleNotificationTask = Task {
            do {
                let updatedItem = try await interactor.updateEvent(id: eventId, notifyEnabled: enabled)
                mutateEvents { items in
                    if let idx = items.firstIndex(where: { $0.id == updatedItem.id }) {
                        items[idx] = updatedItem
                    }
                }
                selectedEvent = updatedItem
                analytics.trackNotificationToggled(enabled: enabled)
                
                if enabled {
                    notificationService.scheduleNotification(for: updatedItem)
                } else {
                    notificationService.cancelNotification(for: updatedItem.id)
                }
            } catch {
                if !Task.isCancelled {
                    toastManager.showError("Не удалось обновить уведомление")
                }
            }
        }
    }
    
    func toggleRepeatYearly(for eventId: String, enabled: Bool) {
        toggleRepeatYearlyTask?.cancel()
        toggleRepeatYearlyTask = Task {
            do {
                let updatedItem = try await interactor.updateEvent(id: eventId, repeatYearly: enabled)
                mutateEvents { items in
                    if let idx = items.firstIndex(where: { $0.id == updatedItem.id }) {
                        items[idx] = updatedItem
                    }
                }
                selectedEvent = updatedItem
                notificationService.cancelNotification(for: updatedItem.id)
                notificationService.scheduleNotification(for: updatedItem)
            } catch {
                if !Task.isCancelled {
                    toastManager.showError("Не удалось обновить повтор")
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let router: CalendarRouter
    private let interactor: CalendarInteractor
    private let userDefaultsService: UserDefaultsService
    private let notificationService: NotificationService
    private let toastManager: ToastManager
    private let analytics: CalendarAnalytics
    
    private var getEventsTask: Task<Void, Never>?
    private var saveEventTask: Task<Void, Never>?
    private var deleteEventTask: Task<Void, Never>?
    private var toggleNotificationTask: Task<Void, Never>?
    private var toggleRepeatYearlyTask: Task<Void, Never>?
    
    // MARK: - Private Methods
    
    private func rescheduleNotificationsFromLoadedStateIfNeeded() {
        guard userDefaultsService.notificationsEnabled else { return }
        guard case .loaded(let events) = viewState else { return }
        notificationService.rescheduleNotifications(for: events)
    }
    
    private func mutateEvents(_ transform: (inout [EventItem]) -> Void) {
        var current = events
        transform(&current)
        current.sort { $0.calendarDisplayDate < $1.calendarDisplayDate }
        withAnimation(.easeInOut(duration: 0.3)) {
            viewState = current.isEmpty ? .empty : .loaded(current)
        }
    }
}
