import Apollo
import ApolloAPI

final class AuthorizationInterceptor: ApolloInterceptor {
    
    // MARK: - ApolloInterceptor
    
    var id: String = "AuthorizationInterceptor"
    
    // MARK: - Init
    
    init(tokenStorage: TokenStorage) {
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Internal Methods
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: any RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void
    ) {
        if let token = tokenStorage.accessToken {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }
        
        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
    
    // MARK: - Private Properties
    
    private let tokenStorage: TokenStorage
}
