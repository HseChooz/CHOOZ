import Foundation
import Apollo

@MainActor
final class AppContainer {
    
    // MARK: - Init
    
    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }
    
    // MARK: - Router
    
    let appRouter: AppRouter
    
    // MARK: - Services
    
    lazy var apolloClient: ApolloClient = ApolloClient(url: AppConfig.apiBaseURL)
    lazy var userDefaultsService: UserDefaultsService = UserDefaultsService()
    lazy var tokenStorage: TokenStorage = TokenStorage()
    lazy var googleAuthService: GoogleAuthService = GoogleAuthService(
        apolloClient: apolloClient,
        tokenStorage: tokenStorage
    )
    lazy var toastManager: ToastManager = ToastManager()
    lazy var wishlistService: WishlistService = WishlistService()
    
    // MARK: - ViewModels
    
    lazy var wishlistViewModel: WishlistViewModel = WishlistViewModel(wishlistService: wishlistService)
    
    // MARK: - Factories
    
    lazy var profileFactory: ProfileFactory = ProfileFactory(
        appRouter: appRouter,
        wishlistViewModel: wishlistViewModel
    )
    lazy var calendarFactory: CalendarFactory = CalendarFactory(
        appRouter: appRouter,
        profileFactory: profileFactory
    )
    lazy var mainTabBarFactory: MainTabBarFactory = MainTabBarFactory(
        appRouter: appRouter,
        calendarFactory: calendarFactory
    )
    lazy var authorizationFactory: AuthorizationFactory = AuthorizationFactory(
        appRouter: appRouter,
        googleAuthService: googleAuthService,
        toastManager: toastManager,
        mainTabBarFactory: mainTabBarFactory
    )
    lazy var onboardingFactory: OnboardingFactory = OnboardingFactory(
        appRouter: appRouter,
        userDefaultsService: userDefaultsService,
        authorizationFactory: authorizationFactory
    )
}
