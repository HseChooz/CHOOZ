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
    
    lazy var tokenStorage: TokenStorage = TokenStorage()
    lazy var userDefaultsService: UserDefaultsService = UserDefaultsService()
    lazy var toastManager: ToastManager = ToastManager()
    lazy var profileService: ProfileService = ProfileService(apolloClient: apolloClient)
    lazy var wishlistService: WishlistService = WishlistService(apolloClient: apolloClient)
    
    lazy var refreshClient: ApolloClient = ApolloClient(url: AppConfig.apiBaseURL)
    
    lazy var apolloClient: ApolloClient = {
        let store = ApolloStore()
        let urlSessionClient = URLSessionClient()
        let provider = AuthInterceptorProvider(
            store: store,
            client: urlSessionClient,
            tokenStorage: tokenStorage,
            refreshClient: refreshClient,
            onSessionExpired: { [weak self] in
                Task { @MainActor [weak self] in
                    self?.sessionService.handleSessionExpired()
                }
            }
        )
        let transport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: AppConfig.apiBaseURL
        )
        return ApolloClient(networkTransport: transport, store: store)
    }()
    
    lazy var googleAuthService: GoogleAuthService = GoogleAuthService(
        apolloClient: apolloClient,
        tokenStorage: tokenStorage
    )
    lazy var yandexAuthService: YandexAuthService = {
        let service = YandexAuthService(
            apolloClient: apolloClient,
            tokenStorage: tokenStorage
        )
        service.activate()
        return service
    }()
    
    lazy var sessionService: SessionService = SessionService(
        apolloClient: apolloClient,
        tokenStorage: tokenStorage,
        appRouter: appRouter,
        authorizationFactory: authorizationFactory
    )
    
    // MARK: - ViewModels
    
    lazy var wishlistViewModel: WishlistViewModel = WishlistViewModel(wishlistService: wishlistService)
    
    // MARK: - Factories
    
    lazy var profileFactory: ProfileFactory = ProfileFactory(
        appRouter: appRouter,
        profileService: profileService,
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
        yandexAuthService: yandexAuthService,
        toastManager: toastManager,
        mainTabBarFactory: mainTabBarFactory
    )
    lazy var onboardingFactory: OnboardingFactory = OnboardingFactory(
        appRouter: appRouter,
        userDefaultsService: userDefaultsService,
        authorizationFactory: authorizationFactory
    )
}
