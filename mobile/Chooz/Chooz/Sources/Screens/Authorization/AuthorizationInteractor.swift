import Foundation

@MainActor
final class AuthorizationInteractor {
    
    // MARK: Init
    
    init(
        appRouter: AppRouter,
        appleAuthService: AppleAuthService,
        googleAuthService: GoogleAuthService,
        yandexAuthService: YandexAuthService
    ) {
        self.appRouter = appRouter
        self.appleAuthService = appleAuthService
        self.googleAuthService = googleAuthService
        self.yandexAuthService = yandexAuthService
    }
    
    // MARK: - Internal Methods
    
    func signInWithApple() async throws {
        guard let topViewController = appRouter.topViewController else {
            throw AuthError.unknown
        }
        
        try await appleAuthService.signIn(presenting: topViewController)
    }
    
    func signInWithGoogle() async throws {
        guard let topViewController = appRouter.topViewController else {
            throw AuthError.unknown
        }
        
        try await googleAuthService.signIn(presenting: topViewController)
    }
    
    func signInWithYandex() async throws {
        guard let topViewController = appRouter.topViewController else {
            throw AuthError.unknown
        }
        
        try await yandexAuthService.signIn(presenting: topViewController)
    }
    
    // MARK: - Private Properties
    
    private let appRouter: AppRouter
    private let appleAuthService: AppleAuthService
    private let googleAuthService: GoogleAuthService
    private let yandexAuthService: YandexAuthService
}
