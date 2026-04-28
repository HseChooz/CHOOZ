import Foundation

@MainActor
protocol DebugPanelFactoryDeps {
    var notificationService: NotificationService { get }
    var toastManager: ToastManager { get }
}

@MainActor
struct DebugPanelFactoryDepsImpl: DebugPanelFactoryDeps {
    let notificationService: NotificationService
    let toastManager: ToastManager
}
