import UIKit
import SwiftUI

@MainActor
final class CalendarFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        profileFactory: ProfileFactory,
        calendarService: CalendarService,
        notificationService: NotificationService,
        toastManager: ToastManager
    ) {
        self.appRouter = appRouter
        self.profileFactory = profileFactory
        self.calendarService = calendarService
        self.notificationService = notificationService
        self.toastManager = toastManager
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = CalendarRouter(appRouter: appRouter, profileFactory: profileFactory)
        let interactor = CalendarInteractor(calendarService: calendarService)
        let viewModel = CalendarViewModel(
            router: router,
            interactor: interactor,
            notificationService: notificationService,
            toastManager: toastManager
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
    private let notificationService: NotificationService
    private let toastManager: ToastManager
}
