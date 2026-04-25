import Foundation
import Apollo

protocol CollectionItemDetailsService {
    func fetchCollectionItemDetails(collectionSlug: String, itemId: String) async throws -> CollectionItemDetailsPayload
}

final class CollectionItemDetailsServiceImpl: CollectionItemDetailsService {
    
    // MARK: - Init
    
    init(apolloClient: ApolloClient) {
        self.apolloClient = apolloClient
    }
    
    // MARK: - Internal Methods
    
    func fetchCollectionItemDetails(collectionSlug: String, itemId: String) async throws -> CollectionItemDetailsPayload {
        let result: Result<CollectionItemDetailsPayload, Error> = await withCheckedContinuation { continuation in
            apolloClient.fetch(
                query: ChoozAPI.CollectionQuery(slug: collectionSlug),
                cachePolicy: .fetchIgnoringCacheCompletely
            ) { result in
                switch result {
                case .success(let graphQLResult):
                    guard let collection = graphQLResult.data?.collection,
                          let item = collection.items.first(where: { $0.id == itemId })
                    else {
                        continuation.resume(returning: .failure(CollectionItemDetailsErrorType.unknown))
                        return
                    }
                    
                    continuation.resume(returning: .success(
                        CollectionItemDetailsPayload(
                            id: item.id,
                            wishItemId: item.wishItemId,
                            title: item.title,
                            description: item.description,
                            link: item.link.flatMap(URL.init(string:)),
                            price: item.price.map { String($0) },
                            currency: item.currency.flatMap { WishCurrency(rawValue: $0.uppercased()) },
                            imageUrl: item.imageUrl.flatMap(URL.init(string:)),
                            isAdded: item.isAdded
                        )
                    ))
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
