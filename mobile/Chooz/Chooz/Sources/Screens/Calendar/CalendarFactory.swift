import UIKit
import SwiftUI

@MainActor
final class CalendarFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        profileFactory: ProfileFactory,
        calendarService: CalendarService,
        userDefaultsService: UserDefaultsService,
        notificationService: NotificationService,
        toastManager: ToastManager,
        analyticsService: AnalyticsService
    ) {
        self.appRouter = appRouter
        self.profileFactory = profileFactory
        self.calendarService = calendarService
        self.userDefaultsService = userDefaultsService
        self.notificationService = notificationService
        self.toastManager = toastManager
        self.analyticsService = analyticsService
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = CalendarRouter(appRouter: appRouter, profileFactory: profileFactory)
        let interactor = CalendarInteractor(calendarService: calendarService)
        let analytics = CalendarAnalytics(analyticsService: analyticsService)
        let viewModel = CalendarViewModel(
            router: router,
            interactor: interactor,
            userDefaultsService: userDefaultsService,
            notificationService: notificationService,
            toastManager: toastManager,
            analytics: analytics
        )
        let view = CalendarView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.navigationBar.prefersLargeTitles = false
        
        return navigationController
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let profileFactory: ProfileFactory
    private let calendarService: CalendarService
    private let userDefaultsService: UserDefaultsService
    private let notificationService: NotificationService
    private let toastManager: ToastManager
    private let analyticsService: AnalyticsService
}
