import UIKit
import SwiftUI

@MainActor
final class SettingsFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        sessionServiceProvider: @escaping () -> SessionService,
        toastManager: ToastManager
    ) {
        self.appRouter = appRouter
        self.sessionServiceProvider = sessionServiceProvider
        self.toastManager = toastManager
    }
    
    // MARK: - Internal Methods
    
    func makeScreen() -> UIViewController {
        let router = SettingsRouter(appRouter: appRouter)
        let viewModel = SettingsViewModel(router: router, sessionService: sessionServiceProvider(), toastManager: toastManager)
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
    private let toastManager: ToastManager
}
