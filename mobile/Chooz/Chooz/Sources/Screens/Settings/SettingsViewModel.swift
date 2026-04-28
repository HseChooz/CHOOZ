import SwiftUI
import UIKit
import Observation

@MainActor
protocol SettingsViewModel: AnyObject {
    var notificationsEnabled: Bool { get set }
    var isDebugPannelAvailable: Bool { get }
    
    func onAppear()
    func logout()
    func deleteAccount()
    func openDebugPanel()
}

@MainActor
@Observable
final class SettingsViewModelImpl: SettingsViewModel {
    
    // MARK: - Internal Properties
    
    var notificationsEnabled: Bool = false {
        didSet {
            guard !isApplyingNotificationsState,
                  notificationsEnabled != oldValue else { return }
            if notificationsEnabled {
                handleNotificationsEnable()
            } else {
                analytics.trackNotificationsToggled(enabled: false, source: "settings")
                deps.userDefaultsService.notificationsEnabled = false
                deps.notificationService.cancelAllNotifications()
            }
        }
    }
    
    var isDebugPannelAvailable: Bool = false
    
    // MARK: - Init
    
    init(
        router: SettingsRouter,
        analytics: SettingsAnalytics,
        calendarInteractor: CalendarInteractor,
        deps: SettingsViewModelDeps
    ) {
        self.router = router
        self.analytics = analytics
        self.calendarInteractor = calendarInteractor
        self.deps = deps
        notificationsEnabled = deps.userDefaultsService.notificationsEnabled
        isDebugPannelAvailable = deps.profileService.userId == Static.debugPanelUserId
    }
    
    // MARK: - Internal Methods

    func onAppear() {
        applyNotificationsState(deps.userDefaultsService.notificationsEnabled)
        syncNotificationsState()
        updateDebugPanelAvailability()

        guard deps.profileService.userId == nil else { return }

        loadProfileTask?.cancel()
        loadProfileTask = Task {
            await deps.profileService.fetchMe()

            guard !Task.isCancelled else { return }
            updateDebugPanelAvailability()
        }
    }
    
    func logout() {
        analytics.trackLogout()
        deps.notificationService.cancelAllNotifications()
        deps.sessionService.handleSessionExpired()
        Task { [deps] in
            try? await Task.sleep(for: .seconds(0.5))
            deps.toastManager.showInfo("Вы вышли из аккаунта", subtitle: "Все ваши данные сохранены")
        }
    }
    
    func deleteAccount() {
        deleteAccountTask?.cancel()
        deleteAccountTask = Task {
            do {
                analytics.trackAccountDeleted()
                deps.notificationService.cancelAllNotifications()
                try await deps.sessionService.deleteAccount()
                try? await Task.sleep(for: .seconds(0.5))
                deps.toastManager.showError(
                    "Ваш аккаунт удален",
                    subtitle: "Все ваши данные были стерты"
                )
            } catch {
                if !Task.isCancelled {
                    deps.toastManager.showError("Не удалось удалить аккаунт")
                }
            }
        }
    }
    
    func openDebugPanel() {
        guard isDebugPannelAvailable else { return }
        router.routeTo(destination: .debugPanel)
    }

    // MARK: - Private Types

    private enum Static {
        static let debugPanelUserId = "2"
    }
    
    // MARK: - Private Properties
    
    private let router: SettingsRouter
    private let analytics: SettingsAnalytics
    private let calendarInteractor: CalendarInteractor
    private let deps: SettingsViewModelDeps
    
    private var deleteAccountTask: Task<Void, Never>?
    private var loadProfileTask: Task<Void, Never>?
    private var syncNotificationsTask: Task<Void, Never>?
    private var isApplyingNotificationsState = false
    
    // MARK: - Private Methods
    
    private func rescheduleNotificationsFromCalendar() async {
        do {
            let events = try await calendarInteractor.getEvents()
            deps.notificationService.rescheduleNotifications(for: events)
        } catch {
            // Календарь обновит расписание при следующем успешном запросе или pull-to-refresh.
        }
    }
    
    private func handleNotificationsEnable() {
        Task {
            let status = await deps.notificationService.getAuthorizationStatus()
            
            if status == .denied {
                notificationsEnabled = false
                openAppSettings()
                return
            }
            
            let granted = await deps.notificationService.requestPermission()
            deps.userDefaultsService.notificationsEnabled = granted
            if granted {
                analytics.trackNotificationsToggled(enabled: true, source: "settings")
                await rescheduleNotificationsFromCalendar()
            } else {
                notificationsEnabled = false
            }
        }
    }
    
    private func syncNotificationsState() {
        syncNotificationsTask?.cancel()
        syncNotificationsTask = Task {
            await deps.notificationService.syncPermissionWithToggle()
            
            guard !Task.isCancelled else { return }
            applyNotificationsState(deps.userDefaultsService.notificationsEnabled)
        }
    }

    private func applyNotificationsState(_ isEnabled: Bool) {
        isApplyingNotificationsState = true
        notificationsEnabled = isEnabled
        isApplyingNotificationsState = false
    }

    private func updateDebugPanelAvailability() {
        isDebugPannelAvailable = deps.profileService.userId == Static.debugPanelUserId
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
}
