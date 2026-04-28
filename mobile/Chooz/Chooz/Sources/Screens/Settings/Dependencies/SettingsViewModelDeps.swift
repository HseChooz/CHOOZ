import Foundation

@MainActor
protocol SettingsViewModelDeps {
    var profileService: ProfileService { get }
    var sessionService: SessionService { get }
    var userDefaultsService: UserDefaultsService { get }
    var notificationService: NotificationService { get }
    var toastManager: ToastManager { get }
}
