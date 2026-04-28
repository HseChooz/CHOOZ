import SwiftUI
import Observation

@MainActor
protocol DebugPanelViewModel: AnyObject {
    func sendTestPush()
}

@MainActor
@Observable
final class DebugPanelViewModelImpl: DebugPanelViewModel {

    // MARK: - Init

    init(
        notificationService: NotificationService,
        toastManager: ToastManager
    ) {
        self.notificationService = notificationService
        self.toastManager = toastManager
    }

    // MARK: - Internal Methods

    func sendTestPush() {
        sendTestPushTask?.cancel()
        sendTestPushTask = Task { [notificationService, toastManager] in
            let result = await notificationService.sendDebugNotification()

            switch result {
            case .scheduled:
                break
            case .denied:
                toastManager.showError(
                    "Уведомления отключены",
                    subtitle: "Разрешите уведомления для приложения в системных настройках"
                )
            case .failed:
                toastManager.showError("Не удалось отправить тестовый пуш")
            }
        }
    }

    // MARK: - Private Properties

    private let notificationService: NotificationService
    private let toastManager: ToastManager

    private var sendTestPushTask: Task<Void, Never>?
    
}
