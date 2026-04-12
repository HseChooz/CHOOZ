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
                    print("AppleAuth credential callback: self is nil, cannot resume")
                    continuation.resume(throwing: AuthError.unknown)
                    return
                }
                self.coordinator = nil
                Task { @MainActor in
                    switch result {
                    case .success(let credential):
                        guard let tokenData = credential.identityToken,
                              let tokenString = String(data: tokenData, encoding: .utf8) else {
                            print("AppleAuth missing identityToken bytes=\(credential.identityToken?.count ?? 0)")
                            continuation.resume(throwing: AuthError.unknown)
                            return
                        }
                        let normalizedToken = tokenString.trimmingCharacters(in: .whitespacesAndNewlines)
                        appleAuthLogCredentialMetadata(
                            credential,
                            identityToken: normalizedToken,
                            apiBaseURL: AppConfig.apiBaseURL
                        )
                        do {
                            let authPayload = try await self.loginWithApple(
                                identityToken: normalizedToken,
                                firstName: credential.fullName?.givenName.map { .some($0) } ?? .null,
                                lastName: credential.fullName?.familyName.map { .some($0) } ?? .null
                            )
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
        identityToken: String,
        firstName: GraphQLNullable<String>,
        lastName: GraphQLNullable<String>
    ) async throws -> ChoozAPI.LoginWithAppleMutation.Data.LoginWithApple {
        try await withCheckedThrowingContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.LoginWithAppleMutation(
                    identityToken: identityToken,
                    firstName: firstName,
                    lastName: lastName
                )
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data?.loginWithApple {
                        continuation.resume(returning: data)
                    } else if let error = graphQLResult.errors?.first {
                        appleAuthLogGraphQLErrors(graphQLResult.errors, context: "AppleAuth GraphQL (loginWithApple nil path)")
                        continuation.resume(throwing: self.mapGraphQLError(error))
                    } else {
                        appleAuthLogGraphQLErrors(graphQLResult.errors, context: "AppleAuth GraphQL empty loginWithApple")
                        print("AppleAuth GraphQL hasData=\(graphQLResult.data != nil) dataLoginWithApple=\(String(describing: graphQLResult.data?.loginWithApple))")
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
    
    private func mapGraphQLError(_ error: GraphQLError?) -> AuthError {
        guard let error else {
            print("AppleAuth mapGraphQLError: message is nil")
            return .unknown
        }
        let message = error.message?.lowercased() ?? ""
        let code = (error.extensions?["code"] as? String)?.uppercased()
        
        if code == "APPLE_UNAVAILABLE" {
            return .serverNotResponding
        }
        
        if [
            "INVALID_APPLE_AUDIENCE",
            "INVALID_APPLE_ISSUER",
            "EXPIRED_APPLE_TOKEN",
            "INVALID_APPLE_SIGNATURE",
            "INVALID_APPLE_TOKEN"
        ].contains(code) {
            return .invalidAppleToken
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
        
        print("AppleAuth mapGraphQLError unmapped: \(message)")
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
                print("AppleAuth delegate success but credential is not ASAuthorizationAppleIDCredential type=\(type(of: authorization.credential))")
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
    print("\(context) AuthError=\(error) toastContent=\(String(describing: error.toastContent))")
}

fileprivate func appleAuthLogDetailedError(_ error: Error, context: String) {
    print("\(context) type=\(Swift.type(of: error)) String(describing)=\(String(describing: error)) localized=\(error.localizedDescription)")
    let ns = error as NSError
    print("\(context) NSError domain=\(ns.domain) code=\(ns.code)")
    if !ns.userInfo.isEmpty {
        print("\(context) NSError userInfo=\(ns.userInfo)")
    }
    if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? Error {
        print("\(context) underlying String(describing)=\(String(describing: underlying)) localized=\(underlying.localizedDescription)")
        let u = underlying as NSError
        print("\(context) underlying NSError domain=\(u.domain) code=\(u.code) userInfo=\(u.userInfo)")
    }
    if let auth = error as? ASAuthorizationError {
        print("\(context) ASAuthorizationError code=\(auth.code) description=\(auth.localizedDescription)")
    }
}

fileprivate func appleAuthLogGraphQLErrors(_ errors: [GraphQLError]?, context: String) {
    guard let errors, !errors.isEmpty else {
        print("\(context) GraphQL errors: nil or empty")
        return
    }
    for (index, err) in errors.enumerated() {
        let code = err.extensions?["code"] as? String ?? "nil"
        print("\(context) [\(index)] code=\(code) message=\(err.message ?? "nil") description=\(String(describing: err))")
    }
}

fileprivate func appleAuthLogCredentialMetadata(
    _ credential: ASAuthorizationAppleIDCredential,
    identityToken: String,
    apiBaseURL: URL
) {
    print("AppleAuth request apiBaseURL=\(apiBaseURL.absoluteString)")
    print(
        "AppleAuth credential user=\(appleMask(credential.user)) identityTokenBytes=\(credential.identityToken?.count ?? 0) authCodeBytes=\(credential.authorizationCode?.count ?? 0)"
    )
    
    let parts = identityToken.split(separator: ".", omittingEmptySubsequences: false)
    guard parts.count == 3 else {
        print("AppleAuth token metadata invalidPartsCount=\(parts.count)")
        return
    }
    
    let header = appleDecodeJWTPart(String(parts[0])) ?? [:]
    let payload = appleDecodeJWTPart(String(parts[1])) ?? [:]
    
    let kid = header["kid"] as? String ?? "nil"
    let alg = header["alg"] as? String ?? "nil"
    let aud = appleStringifyJSONValue(payload["aud"])
    let iss = appleStringifyJSONValue(payload["iss"])
    let exp = appleUnixTimestampDescription(payload["exp"])
    let iat = appleUnixTimestampDescription(payload["iat"])
    let sub = appleMask(appleStringifyJSONValue(payload["sub"]))
    
    print(
        "AppleAuth token header kid=\(kid) alg=\(alg) payload aud=\(aud) iss=\(iss) sub=\(sub) iat=\(iat) exp=\(exp)"
    )
}

fileprivate func appleDecodeJWTPart(_ part: String) -> [String: Any]? {
    var base64 = part.replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    
    let padding = (4 - base64.count % 4) % 4
    if padding > 0 {
        base64.append(String(repeating: "=", count: padding))
    }
    
    guard let data = Data(base64Encoded: base64) else {
        return nil
    }
    
    guard let object = try? JSONSerialization.jsonObject(with: data),
          let dictionary = object as? [String: Any] else {
        return nil
    }
    
    return dictionary
}

fileprivate func appleUnixTimestampDescription(_ value: Any?) -> String {
    if let number = value as? NSNumber {
        let date = Date(timeIntervalSince1970: number.doubleValue)
        return ISO8601DateFormatter().string(from: date)
    }
    return "nil"
}

fileprivate func appleStringifyJSONValue(_ value: Any?) -> String {
    switch value {
    case let string as String:
        return string
    case let array as [String]:
        return array.joined(separator: ",")
    case let number as NSNumber:
        return number.stringValue
    default:
        return "nil"
    }
}

fileprivate func appleMask(_ value: String) -> String {
    guard value.count > 10 else { return value }
    let prefix = value.prefix(4)
    let suffix = value.suffix(4)
    return "\(prefix)…\(suffix)"
}
