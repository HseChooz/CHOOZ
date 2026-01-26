import Apollo
import GoogleSignIn

@MainActor
final class GoogleAuthService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient, tokenStorage: TokenStorage) {
        self.apolloClient = apolloClient
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Internal Methods
    
    func signIn(
        presenting viewController: UIViewController
    ) async throws -> ChoozAPI.LoginWithGoogleMutation.Data.LoginWithGoogle {
        do {
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            let user = try await signInResult.user.refreshTokensIfNeeded()
            
            guard let idToken = user.idToken?.tokenString else {
                throw AuthError.unknown
            }
            
            let authPayload = try await loginWithGoogle(idToken: idToken)
            
            tokenStorage.accessToken = authPayload.accessToken
            tokenStorage.refreshToken = authPayload.refreshToken
            
            return authPayload
        } catch let error as AuthError {
            throw error
        } catch let error as NSError {
            throw mapError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        tokenStorage.clear()
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
    private let tokenStorage: TokenStorage
    
    // MARK: - Private Methods
    
    private func loginWithGoogle(
        idToken: String
    ) async throws -> ChoozAPI.LoginWithGoogleMutation.Data.LoginWithGoogle {
        try await withCheckedThrowingContinuation { continuation in
            apolloClient.perform(mutation: ChoozAPI.LoginWithGoogleMutation(idToken: idToken)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.loginWithGoogle {
                        continuation.resume(returning: data)
                    } else if let error = graphQLResult.errors?.first {
                        continuation.resume(throwing: self.mapGraphQLError(error.message))
                    } else {
                        continuation.resume(throwing: AuthError.unknown)
                    }
                case .failure(let error):
                    continuation.resume(throwing: self.mapNetworkError(error as NSError))
                }
            }
        }
    }
    
    private func mapError(_ error: NSError) -> AuthError {
        if error.domain == "com.google.GIDSignIn" && error.code == -5 {
            return .cancelled
        }
        
        if error.domain == NSURLErrorDomain {
            return mapNetworkError(error)
        }
        
        return .unknown
    }
    
    private func mapNetworkError(_ error: NSError) -> AuthError {
        switch error.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .noConnection
        case NSURLErrorTimedOut:
            return .serverNotResponding
        case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost:
            return .serverNotResponding
        default:
            return .noConnection
        }
    }
    
    private func mapGraphQLError(_ message: String?) -> AuthError {
        guard let message = message?.lowercased() else {
            return .unknown
        }
        
        if message.contains("deleted") || message.contains("удален") {
            return .accountDeleted
        }
        
        if message.contains("overload") || message.contains("перегружен") || message.contains("too many") {
            return .serverOverloaded
        }
        
        if message.contains("timeout") || message.contains("не отвечает") {
            return .serverNotResponding
        }
        
        return .unknown
    }
}
