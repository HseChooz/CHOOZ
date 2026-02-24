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
        toastManager: ToastManager
    ) {
        self.appRouter = appRouter
        self.sessionServiceProvider = sessionServiceProvider
        self.userDefaultsService = userDefaultsService
        self.notificationService = notificationService
        self.toastManager = toastManager
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = SettingsRouter(appRouter: appRouter)
        let viewModel = SettingsViewModel(
            router: router,
            sessionService: sessionServiceProvider(),
            userDefaultsService: userDefaultsService,
            notificationService: notificationService,
            toastManager: toastManager
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
    private let toastManager: ToastManager
}
