import UIKit
import SwiftUI

@MainActor
final class CalendarFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        profileFactory: ProfileFactory,
        calendarService: CalendarService,
        toastManager: ToastManager
    ) {
        self.appRouter = appRouter
        self.profileFactory = profileFactory
        self.calendarService = calendarService
        self.toastManager = toastManager
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = CalendarRouter(appRouter: appRouter, profileFactory: profileFactory)
        let interactor = CalendarInteractor(calendarService: calendarService)
        let viewModel = CalendarViewModel(
            router: router,
            interactor: interactor,
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
    private let toastManager: ToastManager
}
