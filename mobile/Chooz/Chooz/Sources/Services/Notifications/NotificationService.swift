import UserNotifications

@MainActor
final class NotificationService: NSObject {
    
    // MARK: - Init
    
    init(userDefaultsService: UserDefaultsService) {
        self.userDefaultsService = userDefaultsService
        super.init()
        center.delegate = self
    }
    
    // MARK: - Internal Methods
    
    @discardableResult
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    
    func isPermissionGranted() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    func syncPermissionWithToggle() async {
        let granted = await isPermissionGranted()
        if !granted {
            userDefaultsService.notificationsEnabled = false
        }
    }
    
    func scheduleNotification(for event: EventItem) {
        guard userDefaultsService.notificationsEnabled,
              event.notifyEnabled,
              isEventDateEligible(event.date) else {
            return
        }
        
        scheduleAllReminders(for: event)
    }
    
    func cancelNotification(for eventId: String) {
        let identifiers = Static.offsets.map { notificationIdentifier(for: eventId, offset: $0) }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    func rescheduleNotifications(for events: [EventItem]) {
        center.removeAllPendingNotificationRequests()
        
        guard userDefaultsService.notificationsEnabled else { return }
        
        for event in events where event.notifyEnabled {
            scheduleNotificationIgnoringGlobalFlag(for: event)
        }
    }
    
    // MARK: - Private Properties
    
    private let userDefaultsService: UserDefaultsService
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Private Methods
    
    private func scheduleNotificationIgnoringGlobalFlag(for event: EventItem) {
        guard isEventDateEligible(event.date) else { return }
        scheduleAllReminders(for: event)
    }
    
    private func scheduleAllReminders(for event: EventItem) {
        let calendar = Calendar.current
        var eventDateComponents = calendar.dateComponents([.year, .month, .day], from: event.date)
        eventDateComponents.hour = Static.eventHour
        eventDateComponents.minute = 0
        
        guard let eventDate = calendar.date(from: eventDateComponents) else { return }
        
        for offset in Static.offsets {
            guard let fireDate = calendar.date(byAdding: .minute, value: -offset.totalMinutes, to: eventDate),
                  fireDate > .now else {
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = event.title
            content.body = offset.body(eventTitle: event.title)
            content.sound = .default
            
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: event.id, offset: offset),
                content: content,
                trigger: trigger
            )
            
            center.add(request)
        }
    }
    
    private func isEventDateEligible(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfEvent = calendar.startOfDay(for: date)
        return startOfEvent >= startOfToday
    }
    
    private func notificationIdentifier(for eventId: String, offset: ReminderOffset) -> String {
        "event_\(eventId)_\(offset.suffix)"
    }
    
    // MARK: - Private Types
    
    private struct ReminderOffset {
        let hours: Int
        let minutes: Int
        let suffix: String
        let label: String
        
        init(hours: Int, minutes: Int = 0, suffix: String, label: String) {
            self.hours = hours
            self.minutes = minutes
            self.suffix = suffix
            self.label = label
        }
        
        var totalMinutes: Int { hours * 60 + minutes }
        
        func body(eventTitle: String) -> String {
            return "Событие \(eventTitle) начнется \(label.lowercased())"
        }
    }
    
    private enum Static {
        static let eventHour = 10
        
        static let offsets: [ReminderOffset] = [
            ReminderOffset(hours: 12, suffix: "12h", label: "Через 12 часов"),
            ReminderOffset(hours: 1, suffix: "1h", label: "Через 1 час"),
            ReminderOffset(hours: 0, minutes: 15, suffix: "15m", label: "Через 15 минут"),
        ]
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
