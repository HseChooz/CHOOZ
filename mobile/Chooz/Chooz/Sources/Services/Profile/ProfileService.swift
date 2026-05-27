import Foundation
import Apollo
import Observation

@MainActor
protocol ProfileServicing: AnyObject {
    var userId: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var isLoading: Bool { get }

    func fetchMe() async
    func prepareWishlistShareLink() async throws -> URL
}

@MainActor
@Observable
final class ProfileService: ProfileServicing {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    // MARK: - Internal Properties
    
    private(set) var userId: String?
    private(set) var firstName: String?
    private(set) var lastName: String?
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    // MARK: - Internal Methods
    
    func fetchMe() async {
        isLoading = true
        errorMessage = nil
        
        let result: Result<(id: String, firstName: String, lastName: String), Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.MeQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let me = graphQLResult.data?.me {
                        continuation.resume(returning: .success((me.id, me.firstName, me.lastName)))
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
        case .success(let profile):
            userId = profile.id
            firstName = profile.firstName
            lastName = profile.lastName
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    func prepareWishlistShareLink() async throws -> URL {
        let result: Result<URL, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.PrepareWishlistShareLinkMutation()
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let urlString = graphQLResult.data?.prepareWishlistShareLink.url,
                       let url = URL(string: urlString) {
                        continuation.resume(returning: .success(url))
                    } else {
                        let message = graphQLResult.errors?.first?.message ?? "Не удалось поделиться вишлистом"
                        let error = NSError(
                            domain: "ProfileService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: message]
                        )
                        continuation.resume(returning: .failure(error))
                    }

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        return try result.get()
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient
}
