import Apollo
import YandexLoginSDK

enum SessionValidationResult {
    case valid
    case invalid
    case networkError
}

@MainActor
final class SessionService {
    
    // MARK: - Init
    
    init(
        apolloClient: ApolloClient,
        tokenStorage: TokenStorage,
        appRouter: AppRouter,
        authorizationFactory: AuthorizationFactory
    ) {
        self.apolloClient = apolloClient
        self.tokenStorage = tokenStorage
        self.appRouter = appRouter
        self.authorizationFactory = authorizationFactory
    }
    
    // MARK: - Internal Methods
    
    func validateSession() async -> SessionValidationResult {
        guard tokenStorage.isLoggedIn else { return .invalid }
        
        switch await fetchMe() {
        case .success:
            return .valid
        case .authFailure:
            break
        case .networkError:
            return .networkError
        }
        
        switch await tryRefreshToken() {
        case .success:
            break
        case .authFailure:
            return .invalid
        case .networkError:
            return .networkError
        }
        
        switch await fetchMe() {
        case .success:
            return .valid
        case .authFailure:
            return .invalid
        case .networkError:
            return .networkError
        }
    }
    
    func handleSessionExpired() {
        tokenStorage.clear()
        try? YandexLoginSDK.shared.logout()
        
        let vc = authorizationFactory.makeScreen()
        appRouter.setRoot(vc, animated: true)
    }
    
    // MARK: - Private Types
    
    private enum RequestResult {
        case success
        case authFailure
        case networkError
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
    private let tokenStorage: TokenStorage
    private let appRouter: AppRouter
    private let authorizationFactory: AuthorizationFactory
    
    // MARK: - Private Methods
    
    private func fetchMe() async -> RequestResult {
        await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.MeQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if graphQLResult.data?.me != nil {
                        continuation.resume(returning: .success)
                    } else {
                        continuation.resume(returning: .authFailure)
                    }
                case .failure:
                    continuation.resume(returning: .networkError)
                }
            }
        }
    }
    
    private func tryRefreshToken() async -> RequestResult {
        guard let refreshToken = tokenStorage.refreshToken else { return .authFailure }
        
        return await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.RefreshTokenMutation(refreshToken: refreshToken)
            ) { [weak self] result in
                guard let self else {
                    continuation.resume(returning: .authFailure)
                    return
                }
                
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.refreshToken {
                        self.tokenStorage.accessToken = data.accessToken
                        self.tokenStorage.refreshToken = data.refreshToken
                        continuation.resume(returning: .success)
                    } else {
                        continuation.resume(returning: .authFailure)
                    }
                case .failure:
                    continuation.resume(returning: .networkError)
                }
            }
        }
    }
}
