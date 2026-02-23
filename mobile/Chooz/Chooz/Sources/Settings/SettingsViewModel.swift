import SwiftUI
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Init
    
    init(
        router: SettingsRouter,
        sessionService: SessionService,
        toastManager: ToastManager
    ) {
        self.router = router
        self.sessionService = sessionService
        self.toastManager = toastManager
    }
    
    // MARK: - Internal Methods
    
    func logout() {
        sessionService.handleSessionExpired()
        Task { [toastManager] in
            try? await Task.sleep(for: .seconds(0.5))
            toastManager.showInfo("Вы вышли из аккаунта", subtitle: "Все ваши данные сохранены")
        }
    }
    
    // MARK: - Private Properties
    
    private let router: SettingsRouter
    private let sessionService: SessionService
    private let toastManager: ToastManager
}
