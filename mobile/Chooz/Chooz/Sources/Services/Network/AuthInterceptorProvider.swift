import Apollo
import ApolloAPI

final class AuthInterceptorProvider: DefaultInterceptorProvider {
    
    // MARK: - Init
    
    init(
        store: ApolloStore,
        client: URLSessionClient,
        tokenStorage: TokenStorage,
        refreshClient: ApolloClient,
        onSessionExpired: @escaping @Sendable () -> Void
    ) {
        self.tokenStorage = tokenStorage
        self.refreshClient = refreshClient
        self.onSessionExpired = onSessionExpired
        super.init(client: client, shouldInvalidateClientOnDeinit: true, store: store)
    }
    
    // MARK: - Internal Methods
    
    override func interceptors<Operation: GraphQLOperation>(
        for operation: Operation
    ) -> [any ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        
        interceptors.insert(
            AuthorizationInterceptor(tokenStorage: tokenStorage),
            at: 0
        )
        
        interceptors.append(
            TokenRefreshInterceptor(
                tokenStorage: tokenStorage,
                refreshClient: refreshClient,
                onSessionExpired: onSessionExpired
            )
        )
        
        return interceptors
    }
    
    // MARK: - Private Properties
    
    private let tokenStorage: TokenStorage
    private let refreshClient: ApolloClient
    private let onSessionExpired: @Sendable () -> Void
}
