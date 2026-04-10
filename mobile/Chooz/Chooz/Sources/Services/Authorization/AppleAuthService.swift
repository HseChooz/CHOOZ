import Apollo
import AuthenticationServices
import Foundation
import UIKit

@MainActor
final class AppleAuthService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient, tokenStorage: TokenStorage) {
        self.apolloClient = apolloClient
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Internal Methods
    
    func signIn(presenting viewController: UIViewController) async throws {
        let coordinator = AppleSignInCoordinator()
        coordinator.presentingViewController = viewController
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            coordinator.onCredentialResult = { [weak self] result in
                guard let self else {
                    print("😭 AppleAuth credential callback: self is nil, cannot resume")
                    continuation.resume(throwing: AuthError.unknown)
                    return
                }
                self.coordinator = nil
                Task { @MainActor in
                    switch result {
                    case .success(let credential):
                        guard let tokenData = credential.identityToken,
                              let tokenString = String(data: tokenData, encoding: .utf8) else {
                            print("😭 AppleAuth missing identityToken bytes=\(credential.identityToken?.count ?? 0)")
                            continuation.resume(throwing: AuthError.unknown)
                            return
                        }
                        do {
                            let authPayload = try await self.loginWithApple(identityToken: tokenString)
                            self.tokenStorage.accessToken = authPayload.accessToken
                            self.tokenStorage.refreshToken = authPayload.refreshToken
                            continuation.resume()
                        } catch let error as AuthError {
                            appleAuthLogAuthError(error, context: "AppleAuth loginWithApple mutation")
                            continuation.resume(throwing: error)
                        } catch {
                            appleAuthLogDetailedError(error, context: "AppleAuth loginWithApple mutation unexpected")
                            continuation.resume(throwing: AuthError.unknown)
                        }
                    case .failure(let error):
                        if let authError = error as? AuthError {
                            appleAuthLogAuthError(authError, context: "AppleAuth ASAuthorization")
                            continuation.resume(throwing: authError)
                        } else {
                            appleAuthLogDetailedError(error, context: "AppleAuth ASAuthorization raw")
                            continuation.resume(throwing: self.mapAppleSessionError(error))
                        }
                    }
                }
            }
            
            self.coordinator = coordinator
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = coordinator
            authorizationController.presentationContextProvider = coordinator
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
    private let tokenStorage: TokenStorage
    
    private var coordinator: AppleSignInCoordinator?
    
    // MARK: - Private Methods
    
    private func loginWithApple(
        identityToken: String
    ) async throws -> ChoozAPI.LoginWithAppleMutation.Data.LoginWithApple {
        try await withCheckedThrowingContinuation { continuation in
            apolloClient.perform(mutation: ChoozAPI.LoginWithAppleMutation(identityToken: identityToken)) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.loginWithApple {
                        continuation.resume(returning: data)
                    } else if let error = graphQLResult.errors?.first {
                        appleAuthLogGraphQLErrors(graphQLResult.errors, context: "AppleAuth GraphQL (loginWithApple nil path)")
                        continuation.resume(throwing: self.mapGraphQLError(error.message))
                    } else {
                        appleAuthLogGraphQLErrors(graphQLResult.errors, context: "AppleAuth GraphQL empty loginWithApple")
                        print("😭 AppleAuth GraphQL hasData=\(graphQLResult.data != nil) dataLoginWithApple=\(String(describing: graphQLResult.data?.loginWithApple))")
                        continuation.resume(throwing: AuthError.unknown)
                    }
                case .failure(let error):
                    appleAuthLogDetailedError(error, context: "AppleAuth Apollo perform")
                    continuation.resume(throwing: self.mapNetworkError(error as NSError))
                }
            }
        }
    }
    
    private func mapAppleSessionError(_ error: Error) -> AuthError {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            return .cancelled
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
            print("😭 AppleAuth mapGraphQLError: message is nil")
            return .unknown
        }
        
        if message.contains("invalid apple token") || message.contains("invalid apple") {
            return .invalidAppleToken
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
        
        print("😭 AppleAuth mapGraphQLError unmapped: \(message)")
        return .unknown
    }
}

// MARK: - AppleSignInCoordinator

private final class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {
    
    weak var presentingViewController: UIViewController?
    var onCredentialResult: ((Result<ASAuthorizationAppleIDCredential, Error>) -> Void)?
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = presentingViewController?.view.window {
            return window
        }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
            ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first!
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                self.onCredentialResult?(.success(appleIDCredential))
            default:
                print("😭 AppleAuth delegate success but credential is not ASAuthorizationAppleIDCredential type=\(type(of: authorization.credential))")
                self.onCredentialResult?(.failure(AuthError.unknown))
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                self.onCredentialResult?(.failure(AuthError.cancelled))
            } else {
                appleAuthLogDetailedError(error, context: "AppleAuth delegate didCompleteWithError")
                self.onCredentialResult?(.failure(error))
            }
        }
    }
}

// MARK: - Apple auth debug logging

fileprivate func appleAuthLogAuthError(_ error: AuthError, context: String) {
    print("😭 \(context) AuthError=\(error) toastContent=\(String(describing: error.toastContent))")
}

fileprivate func appleAuthLogDetailedError(_ error: Error, context: String) {
    print("😭 \(context) type=\(Swift.type(of: error)) String(describing)=\(String(describing: error)) localized=\(error.localizedDescription)")
    let ns = error as NSError
    print("😭 \(context) NSError domain=\(ns.domain) code=\(ns.code)")
    if !ns.userInfo.isEmpty {
        print("😭 \(context) NSError userInfo=\(ns.userInfo)")
    }
    if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? Error {
        print("😭 \(context) underlying String(describing)=\(String(describing: underlying)) localized=\(underlying.localizedDescription)")
        let u = underlying as NSError
        print("😭 \(context) underlying NSError domain=\(u.domain) code=\(u.code) userInfo=\(u.userInfo)")
    }
    if let auth = error as? ASAuthorizationError {
        print("😭 \(context) ASAuthorizationError code=\(auth.code) description=\(auth.localizedDescription)")
    }
}

fileprivate func appleAuthLogGraphQLErrors(_ errors: [GraphQLError]?, context: String) {
    guard let errors, !errors.isEmpty else {
        print("😭 \(context) GraphQL errors: nil or empty")
        return
    }
    for (index, err) in errors.enumerated() {
        print("😭 \(context) [\(index)] message=\(err.message ?? "nil") description=\(String(describing: err))")
    }
}
