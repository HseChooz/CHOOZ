import SwiftUI
import UIKit
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Internal Properties
    
    var notificationsEnabled: Bool = false {
        didSet {
            guard notificationsEnabled != oldValue else { return }
            if notificationsEnabled {
                handleNotificationsEnable()
            } else {
                analytics.trackNotificationsToggled(enabled: false, source: "settings")
                userDefaultsService.notificationsEnabled = false
                notificationService.cancelAllNotifications()
            }
        }
    }
    
    // MARK: - Init
    
    init(
        router: SettingsRouter,
        sessionService: SessionService,
        userDefaultsService: UserDefaultsService,
        notificationService: NotificationService,
        calendarInteractor: CalendarInteractor,
        toastManager: ToastManager,
        analytics: SettingsAnalytics
    ) {
        self.router = router
        self.sessionService = sessionService
        self.userDefaultsService = userDefaultsService
        self.notificationService = notificationService
        self.calendarInteractor = calendarInteractor
        self.toastManager = toastManager
        self.analytics = analytics
        self.notificationsEnabled = userDefaultsService.notificationsEnabled
    }
    
    // MARK: - Internal Methods
    
    func logout() {
        analytics.trackLogout()
        notificationService.cancelAllNotifications()
        sessionService.handleSessionExpired()
        Task { [toastManager] in
            try? await Task.sleep(for: .seconds(0.5))
            toastManager.showInfo("Вы вышли из аккаунта", subtitle: "Все ваши данные сохранены")
        }
    }
    
    func deleteAccount() {
        deleteAccountTask?.cancel()
        deleteAccountTask = Task {
            do {
                analytics.trackAccountDeleted()
                notificationService.cancelAllNotifications()
                try await sessionService.deleteAccount()
                try? await Task.sleep(for: .seconds(0.5))
                toastManager.showError(
                    "Ваш аккаунт удален",
                    subtitle: "Все ваши данные были стерты"
                )
            } catch {
                if !Task.isCancelled {
                    toastManager.showError("Не удалось удалить аккаунт")
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let router: SettingsRouter
    private let sessionService: SessionService
    private let userDefaultsService: UserDefaultsService
    private let notificationService: NotificationService
    private let calendarInteractor: CalendarInteractor
    private let toastManager: ToastManager
    private let analytics: SettingsAnalytics
    
    private var deleteAccountTask: Task<Void, Never>?
    
    // MARK: - Private Methods
    
    private func rescheduleNotificationsFromCalendar() async {
        do {
            let events = try await calendarInteractor.getEvents()
            notificationService.rescheduleNotifications(for: events)
        } catch {
            // Календарь обновит расписание при следующем успешном запросе или pull-to-refresh.
        }
    }
    
    private func handleNotificationsEnable() {
        Task {
            let status = await notificationService.getAuthorizationStatus()
            
            if status == .denied {
                notificationsEnabled = false
                openAppSettings()
                return
            }
            
            let granted = await notificationService.requestPermission()
            userDefaultsService.notificationsEnabled = granted
            if granted {
                analytics.trackNotificationsToggled(enabled: true, source: "settings")
                await rescheduleNotificationsFromCalendar()
            } else {
                notificationsEnabled = false
            }
        }
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
}
