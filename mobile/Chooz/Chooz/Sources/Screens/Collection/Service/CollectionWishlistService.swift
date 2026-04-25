import Foundation
import Apollo

protocol CollectionWishlistService {
    func addToWishlist(collectionItemId: String) async throws
    func removeFromWishlist(collectionItemId: String) async throws
}

final class CollectionWishlistServiceImpl: CollectionWishlistService {

    // MARK: - Init

    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }

    // MARK: - Internal Methods

    func addToWishlist(collectionItemId: String) async throws {
        let result: Result<Void, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.AddCollectionItemToWishlistMutation(collectionItemId: collectionItemId)
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if graphQLResult.errors?.isEmpty == false {
                        let message = graphQLResult.errors?.first?.message ?? "Не удалось добавить в вишлист"
                        let error = NSError(
                            domain: "CollectionWishlistService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: message]
                        )
                        continuation.resume(returning: .failure(error))
                    } else {
                        continuation.resume(returning: .success(()))
                    }

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        try result.get()
    }

    func removeFromWishlist(collectionItemId: String) async throws {
        let result: Result<Void, Error> = await withCheckedContinuation { continuation in
            apolloClient.perform(
                mutation: ChoozAPI.RemoveCollectionItemFromWishlistMutation(collectionItemId: collectionItemId)
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    if graphQLResult.errors?.isEmpty == false {
                        let message = graphQLResult.errors?.first?.message ?? "Не удалось убрать из вишлиста"
                        let error = NSError(
                            domain: "CollectionWishlistService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: message]
                        )
                        continuation.resume(returning: .failure(error))
                    } else {
                        continuation.resume(returning: .success(()))
                    }

                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }

        try result.get()
    }

    // MARK: - Private Properties

    private let apolloClient: ApolloClient

}
