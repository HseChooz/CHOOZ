import Foundation
import Apollo
import Observation

struct WishlistShareLinkState: Equatable {
    let url: URL
    let isEnabled: Bool
}

@MainActor
protocol ProfileServicing: AnyObject {
    var userId: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var isLoading: Bool { get }

    func fetchMe() async
    func fetchWishlistShareLink() async throws -> WishlistShareLinkState?
    func prepareWishlistShareLink() async throws -> URL
    func prepareWishlistShareLinkState() async throws -> WishlistShareLinkState
    func disableWishlistShareLink() async throws -> WishlistShareLinkState
    func regenerateWishlistShareLink() async throws -> WishlistShareLinkState
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
        let state = try await prepareWishlistShareLinkState()
        return state.url
    }

    func fetchWishlistShareLink() async throws -> WishlistShareLinkState? {
        let result: Result<WishlistShareLinkState?, Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.MyWishlistShareLinkQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let shareLink = graphQLResult.data?.myWishlistShareLink {
                        continuation.resume(
                            returning: .success(
                                WishlistShareLinkState(
                                    url: URL(string: shareLink.url)!,
                                    isEnabled: shareLink.isEnabled
                                )
                            )
                        )
                    } else {
                        continuation.resume(returning: .success(nil))
                    }

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        return try result.get()
    }

    func prepareWishlistShareLinkState() async throws -> WishlistShareLinkState {
        try await performWishlistShareMutation(
            mutation: ChoozAPI.PrepareWishlistShareLinkMutation(),
            extract: { $0.prepareWishlistShareLink },
            fallbackMessage: "Не удалось подготовить публичную ссылку"
        )
    }

    func disableWishlistShareLink() async throws -> WishlistShareLinkState {
        try await performWishlistShareMutation(
            mutation: ChoozAPI.DisableWishlistShareLinkMutation(),
            extract: { $0.disableWishlistShareLink },
            fallbackMessage: "Не удалось отключить публичную ссылку"
        )
    }

    func regenerateWishlistShareLink() async throws -> WishlistShareLinkState {
        try await performWishlistShareMutation(
            mutation: ChoozAPI.RegenerateWishlistShareLinkMutation(),
            extract: { $0.regenerateWishlistShareLink },
            fallbackMessage: "Не удалось обновить публичную ссылку"
        )
    }
    
    // MARK: - Private Properties
    
    private let apolloClient: ApolloClient

    // MARK: - Private Methods

    private func performWishlistShareMutation<Mutation: GraphQLMutation, Payload>(
        mutation: Mutation,
        extract: @escaping (Mutation.Data) -> Payload?,
        fallbackMessage: String
    ) async throws -> WishlistShareLinkState where Payload: WishlistShareLinkPayload {
        let result: Result<WishlistShareLinkState, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: mutation
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if let payload = graphQLResult.data.flatMap(extract),
                       let url = URL(string: payload.url) {
                        continuation.resume(
                            returning: .success(
                                WishlistShareLinkState(url: url, isEnabled: payload.isEnabled)
                            )
                        )
                    } else {
                        let message = graphQLResult.errors?.first?.message ?? fallbackMessage
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
}

protocol WishlistShareLinkPayload {
    var url: String { get }
    var isEnabled: Bool { get }
}

extension ChoozAPI.MyWishlistShareLinkQuery.Data.MyWishlistShareLink: WishlistShareLinkPayload {}
extension ChoozAPI.PrepareWishlistShareLinkMutation.Data.PrepareWishlistShareLink: WishlistShareLinkPayload {}
extension ChoozAPI.DisableWishlistShareLinkMutation.Data.DisableWishlistShareLink: WishlistShareLinkPayload {}
extension ChoozAPI.RegenerateWishlistShareLinkMutation.Data.RegenerateWishlistShareLink: WishlistShareLinkPayload {}
