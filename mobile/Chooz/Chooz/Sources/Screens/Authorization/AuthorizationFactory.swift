import UIKit
import SwiftUI

@MainActor
struct AuthorizationFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        googleAuthService: GoogleAuthService,
        toastManager: ToastManager,
        mainTabBarFactory: MainTabBarFactory
    ) {
        self.appRouter = appRouter
        self.googleAuthService = googleAuthService
        self.toastManager = toastManager
        self.mainTabBarFactory = mainTabBarFactory
    }
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let router = AuthorizationRouter(appRouter: appRouter, mainTabBarFactory: mainTabBarFactory)
        let interactor = AuthorizationInteractor(appRouter: appRouter, googleAuthService: googleAuthService)
        let viewModel = AuthorizationViewModel(
            interactor: interactor,
            router: router,
            toastManager: toastManager
        )
        let view = AuthorizationView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let googleAuthService: GoogleAuthService
    private let toastManager: ToastManager
    private let mainTabBarFactory: MainTabBarFactory
}
