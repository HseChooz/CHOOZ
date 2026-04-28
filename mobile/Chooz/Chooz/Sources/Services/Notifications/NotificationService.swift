import Foundation
import UserNotifications

@MainActor
final class NotificationService: NSObject {

    // MARK: - Internal Types

    enum DebugNotificationResult {
        case scheduled
        case denied
        case failed
    }
    
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
    
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    func syncPermissionWithToggle() async {
        let granted = await isPermissionGranted()
        if !granted {
            userDefaultsService.notificationsEnabled = false
        }
    }
    
    func scheduleNotification(for event: EventItem) {
        guard userDefaultsService.notificationsEnabled, event.notifyEnabled else {
            return
        }
        
        if event.repeatYearly {
            scheduleYearlyReminders(for: event)
        } else {
            guard isEventDateEligible(event.date) else { return }
            scheduleAllReminders(for: event)
        }
    }
    
    func cancelNotification(for eventId: String) {
        var identifiers = Static.offsets.map { notificationIdentifier(for: eventId, offset: $0) }
        identifiers.append(fallbackNotificationIdentifier(for: eventId))
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

    func sendDebugNotification() async -> DebugNotificationResult {
        let status = await getAuthorizationStatus()

        switch status {
        case .notDetermined:
            _ = await requestPermission()
            let updatedStatus = await getAuthorizationStatus()

            switch updatedStatus {
            case .authorized, .provisional, .ephemeral:
                return await scheduleDebugNotification()
            case .denied:
                return .denied
            default:
                return .failed
            }
        case .authorized, .provisional, .ephemeral:
            return await scheduleDebugNotification()
        case .denied:
            return .denied
        @unknown default:
            return .failed
        }
    }
    
    // MARK: - Private Properties
    
    private let userDefaultsService: UserDefaultsService
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Private Methods
    
    private func scheduleNotificationIgnoringGlobalFlag(for event: EventItem) {
        if event.repeatYearly {
            scheduleYearlyReminders(for: event)
        } else {
            guard isEventDateEligible(event.date) else { return }
            scheduleAllReminders(for: event)
        }
    }
    
    private func scheduleAllReminders(for event: EventItem) {
        let calendar = Calendar.current
        var eventDateComponents = calendar.dateComponents([.year, .month, .day], from: event.date)
        eventDateComponents.hour = Static.eventHour
        eventDateComponents.minute = 0
        
        guard let eventDate = calendar.date(from: eventDateComponents) else { return }
        
        var scheduledAny = false
        
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
            
            addRequest(request)
            scheduledAny = true
        }
        
        if !scheduledAny, eventDate > .now {
            scheduleFallbackReminder(for: event, eventDate: eventDate)
        }
    }
    
    /// Ежегодные напоминания по month/day/hour/minute (тот же `event.id` и суффиксы оффсетов, что и у одноразовых).
    private func scheduleYearlyReminders(for event: EventItem) {
        let calendar = Calendar.current
        let displayDay = calendar.startOfDay(for: event.calendarDisplayDate)
        var dayComponents = calendar.dateComponents([.year, .month, .day], from: displayDay)
        dayComponents.hour = Static.eventHour
        dayComponents.minute = 0
        guard let eventDateTime = calendar.date(from: dayComponents) else { return }
        
        var scheduledAny = false
        
        for offset in Static.offsets {
            guard let fireDate = calendar.date(byAdding: .minute, value: -offset.totalMinutes, to: eventDateTime) else {
                continue
            }
            
            let matchComponents = calendar.dateComponents([.month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: matchComponents, repeats: true)
            
            let content = UNMutableNotificationContent()
            content.title = event.title
            content.body = offset.body(eventTitle: event.title)
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: notificationIdentifier(for: event.id, offset: offset),
                content: content,
                trigger: trigger
            )
            
            addRequest(request)
            scheduledAny = true
        }
        
        if !scheduledAny {
            let matchComponents = calendar.dateComponents([.month, .day, .hour, .minute], from: eventDateTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: matchComponents, repeats: true)
            
            let content = UNMutableNotificationContent()
            content.title = event.title
            content.body = "Событие \(event.title) скоро начнётся"
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: fallbackNotificationIdentifier(for: event.id),
                content: content,
                trigger: trigger
            )
            
            addRequest(request)
        }
    }
    
    private func scheduleFallbackReminder(for event: EventItem, eventDate: Date) {
        let secondsUntilEvent = eventDate.timeIntervalSinceNow
        guard secondsUntilEvent > Static.minimumFireDelaySeconds else { return }
        
        let interval = max(
            Static.minimumFireDelaySeconds,
            min(Static.fallbackLeadSeconds, secondsUntilEvent - 1)
        )
        
        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = "Событие \(event.title) скоро начнётся"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: fallbackNotificationIdentifier(for: event.id),
            content: content,
            trigger: trigger
        )
        
        addRequest(request)
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
    
    private func fallbackNotificationIdentifier(for eventId: String) -> String {
        "event_\(eventId)_fallback"
    }

    private func scheduleDebugNotification() async -> DebugNotificationResult {
        center.removePendingNotificationRequests(withIdentifiers: [Static.debugNotificationIdentifier])

        let content = UNMutableNotificationContent()
        content.title = Static.debugNotificationTitle
        content.body = Static.debugNotificationBody
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Static.debugNotificationDelaySeconds,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: Static.debugNotificationIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await addRequestAwaitingResult(request)
            return .scheduled
        } catch {
            return .failed
        }
    }
    
    private func addRequest(_ request: UNNotificationRequest) {
        center.add(request) { error in
            #if DEBUG
            if let error {
                print("Notification scheduling failed: \(error.localizedDescription)")
            }
            #endif
        }
    }

    private func addRequestAwaitingResult(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
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
        static let fallbackLeadSeconds: TimeInterval = 60
        static let minimumFireDelaySeconds: TimeInterval = 1
        static let debugNotificationDelaySeconds: TimeInterval = 1
        static let debugNotificationIdentifier = "debug_test_push"
        static let debugNotificationTitle = "Тестовый пуш"
        static let debugNotificationBody = "Локальное уведомление из дебаг-панели"
        
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
