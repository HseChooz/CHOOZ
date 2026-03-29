import SwiftUI

@MainActor
struct OnboardingFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        userDefaultsService: UserDefaultsService,
        authorizationFactory: AuthorizationFactory,
        analyticsService: AnalyticsService
    ) {
        self.appRouter = appRouter
        self.userDefaultsService = userDefaultsService
        self.authorizationFactory = authorizationFactory
        self.analyticsService = analyticsService
    }
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let router = OnboardingRouter(
            appRouter: appRouter,
            authorizationFactory: authorizationFactory
        )
        let analytics = OnboardingAnalytics(analyticsService: analyticsService)
        let viewModel = OnboardingViewModel(
            router: router,
            userDefaultsService: userDefaultsService,
            analytics: analytics
        )
        let view = OnboardingView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let userDefaultsService: UserDefaultsService
    private let authorizationFactory: AuthorizationFactory
    private let analyticsService: AnalyticsService
    
}
