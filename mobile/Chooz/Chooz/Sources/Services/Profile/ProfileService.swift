import Foundation
import Apollo
import Observation

@MainActor
@Observable
final class ProfileService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    // MARK: - Internal Properties
    
    private(set) var firstName: String?
    private(set) var lastName: String?
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Internal Methods
    
    func fetchMe() async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<(firstName: String, lastName: String), Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.MeQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let me = graphQLResult.data?.me {
                        continuation.resume(returning: .success((me.firstName, me.lastName)))
                    } else {
                        let error = NSError(
                            domain: "ProfileService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Не удалось получить данные профиля"]
                        )
                        continuation.resume(returning: .failure(error))
                    }
                    
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
        
        isLoading = false
        
        switch result {
        case .success(let name):
            firstName = name.firstName
            lastName = name.lastName
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
}
