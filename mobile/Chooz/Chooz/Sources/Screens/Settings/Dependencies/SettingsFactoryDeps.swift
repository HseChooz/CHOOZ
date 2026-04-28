import Foundation

@MainActor
protocol SettingsFactoryDeps:
    SettingsRouterDeps,
    SettingsViewModelDeps
{
    var analyticsService: AnalyticsService { get }
    var calendarService: CalendarService { get }
}

@MainActor
struct SettingsFactoryDepsImpl: SettingsFactoryDeps {
    let appRouter: AppRouter
    let profileService: ProfileService
    let sessionService: SessionService
    let userDefaultsService: UserDefaultsService
    let notificationService: NotificationService
    let toastManager: ToastManager
    let analyticsService: AnalyticsService
    let calendarService: CalendarService
    let debugPanelFactory: DebugPanelFactory
}
