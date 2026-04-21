import Foundation

@MainActor
protocol AuthorizationInteractorDeps {
    var appRouter: AppRouter { get }
    var appleAuthService: AppleAuthService { get }
    var googleAuthService: GoogleAuthService { get }
    var yandexAuthService: YandexAuthService { get }
}

@MainActor
final class AuthorizationInteractor {
    
    // MARK: Init
    
    init(deps: AuthorizationInteractorDeps) {
        self.deps = deps
    }
    
    // MARK: - Internal Methods
    
    func signInWithApple() async throws {
        guard let topViewController = deps.appRouter.topViewController else {
            throw AuthError.unknown
        }
        
        try await deps.appleAuthService.signIn(presenting: topViewController)
    }
    
    func signInWithGoogle() async throws {
        guard let topViewController = deps.appRouter.topViewController else {
            throw AuthError.unknown
        }
        
        try await deps.googleAuthService.signIn(presenting: topViewController)
    }
    
    func signInWithYandex() async throws {
        guard let topViewController = deps.appRouter.topViewController else {
            throw AuthError.unknown
        }
        
        try await deps.yandexAuthService.signIn(presenting: topViewController)
    }
    
    // MARK: - Private Properties
    
    private let deps: AuthorizationInteractorDeps
}
