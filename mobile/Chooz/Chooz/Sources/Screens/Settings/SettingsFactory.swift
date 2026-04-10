import UIKit
import SwiftUI

@MainActor
final class SettingsFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        sessionServiceProvider: @escaping () -> SessionService,
        userDefaultsService: UserDefaultsService,
        notificationService: NotificationService,
        calendarService: CalendarService,
        toastManager: ToastManager,
        analyticsService: AnalyticsService
    ) {
        self.appRouter = appRouter
        self.sessionServiceProvider = sessionServiceProvider
        self.userDefaultsService = userDefaultsService
        self.notificationService = notificationService
        self.calendarService = calendarService
        self.toastManager = toastManager
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = SettingsRouter(appRouter: appRouter)
        let analytics = SettingsAnalytics(analyticsService: analyticsService)
        let calendarInteractor = CalendarInteractor(calendarService: calendarService)
        let viewModel = SettingsViewModel(
            router: router,
            sessionService: sessionServiceProvider(),
            userDefaultsService: userDefaultsService,
            notificationService: notificationService,
            calendarInteractor: calendarInteractor,
            toastManager: toastManager,
            analytics: analytics
        )
        let view = SettingsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        hostingController.navigationItem.standardAppearance = appearance
        hostingController.navigationItem.scrollEdgeAppearance = appearance
        hostingController.view.tintColor = UIColor(Colors.Blue.blue500)
        
        return hostingController
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let sessionServiceProvider: () -> SessionService
    private let userDefaultsService: UserDefaultsService
    private let notificationService: NotificationService
    private let calendarService: CalendarService
    private let toastManager: ToastManager
    private let analyticsService: AnalyticsService
}
