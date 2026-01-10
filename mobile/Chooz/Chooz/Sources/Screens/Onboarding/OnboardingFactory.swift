import SwiftUI

@MainActor
struct OnboardingFactory {
    
    // MARK: - Init
    
    init(
        appRouter: AppRouter,
        userDefaultsService: UserDefaultsService,
        authorizationFactory: AuthorizationFactory
    ) {
        self.appRouter = appRouter
        self.userDefaultsService = userDefaultsService
        self.authorizationFactory = authorizationFactory
    }
    
    // MARK: - Public Methods
    
    func makeScreen() -> UIViewController {
        let router = OnboardingRouter(
            appRouter: appRouter,
            authorizationFactory: authorizationFactory
        )
        let viewModel = OnboardingViewModel(
            router: router,
            userDefaultsService: userDefaultsService
        )
        let view = OnboardingView(viewModel: viewModel)
        let vc = UIHostingController(rootView: view)
        return vc
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let userDefaultsService: UserDefaultsService
    private let authorizationFactory: AuthorizationFactory
    
}
