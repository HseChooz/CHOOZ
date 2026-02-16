import AuthenticationServices
import Apollo
import UIKit
import YandexLoginSDK

@MainActor
final class YandexAuthService: NSObject {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient, tokenStorage: TokenStorage) {
        self.apolloClient = apolloClient
        self.tokenStorage = tokenStorage
        super.init()
    }
    
    // MARK: - Internal Methods
    
    func activate() {
        do {
            try YandexLoginSDK.shared.activate(with: AppConfig.yandexClientID)
        } catch {
            print("YandexLoginSDK activation error: \(error)")
        }
        YandexLoginSDK.shared.add(observer: self)
    }
    
    func signIn(presenting viewController: UIViewController) async throws {
        do {
            let oauthToken = try await requestAuthorization(presenting: viewController)
            let authPayload = try await loginWithYandex(oauthToken: oauthToken)
            
            tokenStorage.accessToken = authPayload.accessToken
            tokenStorage.refreshToken = authPayload.refreshToken
        } catch let error as AuthError {
            throw error
        } catch let error as NSError {
            print("[YandexAuth] Raw NSError — domain: \(error.domain), code: \(error.code), description: \(error.localizedDescription)")
            throw mapError(error)
        } catch {
            print("[YandexAuth] Unknown error type: \(type(of: error)), description: \(error)")
            throw AuthError.unknown
        }
    }
    
    func signOut() {
        try? YandexLoginSDK.shared.logout()
        tokenStorage.clear()
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
    private let tokenStorage: TokenStorage
    
    private var authContinuation: CheckedContinuation<String, Error>?
    
    // MARK: - Private Methods
    
    private func requestAuthorization(presenting viewController: UIViewController) async throws -> String {
        try? YandexLoginSDK.shared.logout()
        
        return try await withCheckedThrowingContinuation { continuation in
            self.authContinuation = continuation
            do {
                try YandexLoginSDK.shared.authorize(with: viewController)
            } catch {
                self.authContinuation = nil
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func loginWithYandex(
        oauthToken: String
    ) async throws -> ChoozAPI.LoginWithYandexMutation.Data.LoginWithYandex {
        try await withCheckedThrowingContinuation { continuation in
            apolloClient.perform(mutation: ChoozAPI.LoginWithYandexMutation(oauthToken: oauthToken)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.loginWithYandex {
                        continuation.resume(returning: data)
                    } else if let error = graphQLResult.errors?.first {
                        print("[YandexAuth] GraphQL error: \(error.message ?? "no message")")
                        continuation.resume(throwing: self.mapGraphQLError(error.message))
                    } else {
                        print("[YandexAuth] GraphQL returned neither data nor errors")
                        continuation.resume(throwing: AuthError.unknown)
                    }
                case .failure(let error):
                    print("[YandexAuth] Network error: \(error)")
                    continuation.resume(throwing: self.mapNetworkError(error as NSError))
                }
            }
        }
    }
    
    private func mapError(_ error: NSError) -> AuthError {
        if error.domain == ASWebAuthenticationSessionError.errorDomain,
           error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
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

// MARK: - YandexLoginSDKObserver

extension YandexAuthService: YandexLoginSDKObserver {
    
    nonisolated func didFinishLogin(with result: Result<LoginResult, any Error>) {
        switch result {
        case .success:
            print("[YandexAuth] SDK login succeeded, received token")
        case .failure(let error):
            print("[YandexAuth] SDK login failed: \(error)")
        }
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            switch result {
            case .success(let loginResult):
                self.authContinuation?.resume(returning: loginResult.token)
            case .failure(let error):
                self.authContinuation?.resume(throwing: error)
            }
            self.authContinuation = nil
        }
    }
}
