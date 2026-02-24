import SwiftUI
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
        toastManager: ToastManager
    ) {
        self.router = router
        self.sessionService = sessionService
        self.userDefaultsService = userDefaultsService
        self.notificationService = notificationService
        self.toastManager = toastManager
        self.notificationsEnabled = userDefaultsService.notificationsEnabled
    }
    
    // MARK: - Internal Methods
    
    func logout() {
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
    private let toastManager: ToastManager
    
    private var deleteAccountTask: Task<Void, Never>?
    
    // MARK: - Private Methods
    
    private func handleNotificationsEnable() {
        Task {
            let granted = await notificationService.requestPermission()
            userDefaultsService.notificationsEnabled = granted
            if !granted {
                notificationsEnabled = false
                toastManager.showError(
                    "Уведомления отключены",
                    subtitle: "Разрешите уведомления в настройках устройства"
                )
            }
        }
    }
}
