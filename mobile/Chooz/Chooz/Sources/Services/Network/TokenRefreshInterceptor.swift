import Apollo
import ApolloAPI

final class TokenRefreshInterceptor: ApolloInterceptor {
    
    // MARK: - ApolloInterceptor
    
    var id: String = "TokenRefreshInterceptor"
    
    // MARK: - Init
    
    init(
        tokenStorage: TokenStorage,
        refreshClient: ApolloClient,
        onSessionExpired: @escaping @Sendable () -> Void
    ) {
        self.tokenStorage = tokenStorage
        self.refreshClient = refreshClient
        self.onSessionExpired = onSessionExpired
    }
    
    // MARK: - Internal Methods
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self
        ) { [weak self] result in
            guard let self else {
                completion(result)
                return
            }
            
            switch result {
            case .success:
                completion(result)
            case .failure(let error):
                guard self.isAuthError(error),
                      !self.isRefreshOperation(request) else {
                    completion(result)
                    return
                }
                
                self.refreshTokenAndRetry(
                    chain: chain,
                    request: request,
                    completion: completion
                )
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let tokenStorage: TokenStorage
    private let refreshClient: ApolloClient
    private let onSessionExpired: @Sendable () -> Void
    
    // MARK: - Private Methods
    
    private func isAuthError(_ error: Error) -> Bool {
        if let responseCodeError = error as? ResponseCodeInterceptor.ResponseCodeError,
           case .invalidResponseCode(let response, _) = responseCodeError,
           response?.statusCode == 401 {
            return true
        }
        return false
    }
    
    private func isRefreshOperation<Operation: GraphQLOperation>(
        _ request: HTTPRequest<Operation>
    ) -> Bool {
        request.operation is ChoozAPI.RefreshTokenMutation
    }
    
    private func refreshTokenAndRetry<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        guard let refreshToken = tokenStorage.refreshToken else {
            handleSessionExpired()
            completion(.failure(AuthError.unknown))
            return
        }
        
        let mutation = ChoozAPI.RefreshTokenMutation(refreshToken: refreshToken)
        
        refreshClient.perform(mutation: mutation) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let graphQLResult):
                if let data = graphQLResult.data?.refreshToken {
                    self.tokenStorage.accessToken = data.accessToken
                    self.tokenStorage.refreshToken = data.refreshToken
                    
                    request.addHeader(
                        name: "Authorization",
                        value: "Bearer \(data.accessToken)"
                    )
                    chain.retry(request: request, completion: completion)
                } else {
                    self.handleSessionExpired()
                    completion(.failure(AuthError.unknown))
                }
            case .failure:
                self.handleSessionExpired()
                completion(.failure(AuthError.unknown))
            }
        }
    }
    
    private func handleSessionExpired() {
        tokenStorage.clear()
        onSessionExpired()
    }
}
