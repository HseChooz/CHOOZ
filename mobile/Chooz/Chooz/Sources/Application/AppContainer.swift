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
    lazy var analyticsService: AnalyticsService = AnalyticsService()
    lazy var profileService: ProfileService = ProfileService(apolloClient: apolloClient)
    lazy var wishlistService: WishlistService = WishlistService(apolloClient: apolloClient)
    lazy var calendarService: CalendarService = CalendarService(apolloClient: apolloClient)
    lazy var notificationService: NotificationService = NotificationService(userDefaultsService: userDefaultsService)

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

    lazy var appleAuthService: AppleAuthService = AppleAuthService(
        apolloClient: apolloClient,
        tokenStorage: tokenStorage
    )

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

    lazy var deepLinkService: DeepLinkService = DeepLinkService(
        appRouter: appRouter,
        socialProfileFactory: socialProfileFactory
    )

    lazy var mainTabService: MainTabService = MainTabServiceImpl(apolloClient: apolloClient)
    lazy var collectionsListService: CollectionsListService = CollectionsListServiceImpl(apolloClient: apolloClient)
    lazy var collectionService: CollectionService = CollectionServiceImpl(apolloClient: apolloClient)
    lazy var collectionWishlistService: CollectionWishlistService = CollectionWishlistServiceImpl(apolloClient: apolloClient)
    lazy var collectionItemDetailsService: CollectionItemDetailsService = CollectionItemDetailsServiceImpl(apolloClient: apolloClient)
    lazy var notesService: NotesService = NotesServiceImpl(apolloClient: apolloClient)
    lazy var noteActionPerformerProducer: NoteActionPerformerProducer = NoteActionPerformerProducer(
        deps: NoteActionPerformerProducerDepsImpl(notesService: notesService)
    )

    // MARK: - ViewModels

    lazy var wishlistAnalytics: WishlistAnalytics = WishlistAnalytics(analyticsService: analyticsService)

    lazy var wishlistViewModel: WishlistViewModel = WishlistViewModel(
        wishlistService: wishlistService,
        toastManager: toastManager,
        analytics: wishlistAnalytics
    )

    // MARK: - Factories

    lazy var mainTabFactory: MainTabFactory = MainTabFactory(
        deps: MainTabFactoryDepsImpl(
            appRouter: appRouter,
            profileFactory: profileFactory,
            mainTabService: mainTabService,
            calendarFactory: calendarFactory,
            collectionsListFactory: collectionsListFactory,
            collectionFactory: collectionFactory
        )
    )

    lazy var collectionsListFactory: CollectionsListFactory = CollectionsListFactory(
        deps: CollectionsListFactoryDepsImpl(
            appRouter: appRouter,
            collectionFactory: collectionFactory,
            collectionsListService: collectionsListService
        )
    )

    lazy var collectionFactory: CollectionFactory = CollectionFactory(
        deps: CollectionFactoryDepsImpl(
            collectionService: collectionService,
            collectionWishlistService: collectionWishlistService,
            toastManager: toastManager,
            appRouter: appRouter,
            collectionItemDetailsFactory: collectionItemDetailsFactory
        )
    )

    lazy var collectionItemDetailsFactory: CollectionItemDetailsFactory = CollectionItemDetailsFactory(
        deps: CollectionItemDetailsFactoryDepsImpl(
            collectionItemDetailsService: collectionItemDetailsService
        )
    )

    lazy var socialProfileFactory: SocialProfileFactory = SocialProfileFactory(
        appRouter: appRouter,
        wishlistService: wishlistService
    )

    lazy var settingsFactory: SettingsFactory = SettingsFactory(
        appRouter: appRouter,
        sessionServiceProvider: { [unowned self] in self.sessionService },
        userDefaultsService: userDefaultsService,
        notificationService: notificationService,
        calendarService: calendarService,
        toastManager: toastManager,
        analyticsService: analyticsService
    )

    lazy var profileFactory: ProfileFactory = ProfileFactory(
        appRouter: appRouter,
        profileService: profileService,
        wishlistViewModel: wishlistViewModel,
        settingsFactory: settingsFactory,
        analyticsService: analyticsService
    )

    lazy var calendarFactory: CalendarFactory = CalendarFactory(
        appRouter: appRouter,
        profileFactory: profileFactory,
        calendarService: calendarService,
        userDefaultsService: userDefaultsService,
        notificationService: notificationService,
        toastManager: toastManager,
        analyticsService: analyticsService
    )

    lazy var noteFormFactory: NoteFormFactory = NoteFormFactory(
        deps: NoteFormFactoryDepsImpl(toastManager: toastManager)
    )

    lazy var noteDetailsFactory: NoteDetailsFactory = NoteDetailsFactory(
        deps: NoteDetailsFactoryDepsImpl(
            appRouter: appRouter,
            noteFormFactory: noteFormFactory,
            noteActionPerformerProducer: noteActionPerformerProducer,
            toastManager: toastManager
        )
    )

    lazy var notesFactory: NotesFactory = NotesFactory(
        deps: NotesFactoryDepsImpl(
            appRouter: appRouter,
            noteFormFactory: noteFormFactory,
            notesService: notesService,
            noteActionPerformerProducer: noteActionPerformerProducer,
            noteDetailsFactory: noteDetailsFactory
        )
    )

    lazy var favoriteNotesFactory: FavoriteNotesFactory = FavoriteNotesFactory(
        deps: FavoriteNotesFactoryDepsImpl(
            appRouter: appRouter,
            noteFormFactory: noteFormFactory,
            noteDetailsFactory: noteDetailsFactory,
            notesService: notesService,
            noteActionPerformerProducer: noteActionPerformerProducer
        )
    )

    lazy var notesTabFactory: NotesTabFactory = NotesTabFactory(
        deps: NotesTabFactoryDepsImpl(
            appRouter: appRouter,
            profileFactory: profileFactory,
            notesFactory: notesFactory,
            favoriteNotesFactory: favoriteNotesFactory,
            noteActionPerformerProducer: noteActionPerformerProducer,
            toastManager: toastManager
        )
    )

    lazy var appTabBarFactory: AppTabBarFactory = AppTabBarFactory(
        appTabBarDeps: AppTabBarDepsImpl(
            appRouter: appRouter,
            mainTabViewController: mainTabFactory.makeScreen(),
            calendarViewController: calendarFactory.makeScreen(),
            notesTabViewController: notesTabFactory.makeScreen()
        )
    )

    lazy var authorizationFactory: AuthorizationFactory = AuthorizationFactory(
        deps: AuthorizationFactoryDepsImpl(
            appRouter: appRouter,
            appleAuthService: appleAuthService,
            googleAuthService: googleAuthService,
            yandexAuthService: yandexAuthService,
            appTabBarFactory: appTabBarFactory,
            analyticsService: analyticsService,
            toastManager: toastManager
        )
    )

    lazy var onboardingFactory: OnboardingFactory = OnboardingFactory(
        appRouter: appRouter,
        userDefaultsService: userDefaultsService,
        authorizationFactory: authorizationFactory,
        analyticsService: analyticsService
    )

}
