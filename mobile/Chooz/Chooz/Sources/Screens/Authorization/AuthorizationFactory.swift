import UIKit
import SwiftUI

@MainActor
struct AuthorizationFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        appleAuthService: AppleAuthService,
        googleAuthService: GoogleAuthService,
        yandexAuthService: YandexAuthService,
        toastManager: ToastManager,
        mainTabBarFactory: MainTabBarFactory,
        analyticsService: AnalyticsService
    ) {
        self.appRouter = appRouter
        self.appleAuthService = appleAuthService
        self.googleAuthService = googleAuthService
        self.yandexAuthService = yandexAuthService
        self.toastManager = toastManager
        self.mainTabBarFactory = mainTabBarFactory
        self.analyticsService = analyticsService
    }
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let router = AuthorizationRouter(appRouter: appRouter, mainTabBarFactory: mainTabBarFactory)
        let interactor = AuthorizationInteractor(
            appRouter: appRouter,
            appleAuthService: appleAuthService,
            googleAuthService: googleAuthService,
            yandexAuthService: yandexAuthService
        )
        let analytics = AuthorizationAnalytics(analyticsService: analyticsService)
        let viewModel = AuthorizationViewModel(
            interactor: interactor,
            router: router,
            toastManager: toastManager,
            analytics: analytics
        )
        let view = AuthorizationView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let appleAuthService: AppleAuthService
    private let googleAuthService: GoogleAuthService
    private let yandexAuthService: YandexAuthService
    private let toastManager: ToastManager
    private let mainTabBarFactory: MainTabBarFactory
    private let analyticsService: AnalyticsService
}
